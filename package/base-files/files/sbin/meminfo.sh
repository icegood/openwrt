#!/bin/sh

# Default page size for MIPS is 4KB. 
# We'll calculate the KB factor (4 for 4096).
KB=4

#Title		statm Column	Description
#PID		—				Process ID.
#Process	—				The command name (comm).
#VIRT		1st				Virtual Size: Total address space reserved (includes unmapped stuff).
#RES		2nd				Resident Set (RSS): Actual physical RAM being used right now.
#SHR		3rd				Shared Pages: Physical RAM that is backed by a file (like .so libs).
#CODE		4th				Text: The size of the executable code segment.
#DATA		6th				Data/Stack: Private memory used for variables, heap, and the uCode VM state.

# Print Header
printf "%-6s %-30s %-8s %-8s %-8s %-8s %-8s\n" "PID" "COMMAND" "VIRT" "RES" "SHR" "CODE" "DATA"
echo "--------------------------------------------------------------------------------"

for pid_dir in /proc/[0-9]*; do
    pid=${pid_dir##*/}
    [ -f "$pid_dir/statm" ] || continue
    
    # Read statm columns
    read -r m_virt m_res m_shr m_code m_lib m_data m_dt < "$pid_dir/statm"
    
    # Get process name, handle cases where it might be empty
    if [ -f "$pid_dir/comm" ]; then
        name=$(cat "$pid_dir/comm")
    else
        name="unknown"
    fi

    # Format output in Kilobytes
    printf "%-6s %-30s %-7sK %-7sK %-7sK %-7sK %-7sK\n" \
        "$pid" \
        "$name" \
        "$((m_virt * KB))" \
        "$((m_res * KB))" \
        "$((m_shr * KB))" \
        "$((m_code * KB))" \
        "$((m_data * KB))"
done | sort -nk4