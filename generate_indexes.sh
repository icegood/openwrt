#!/bin/bash
set -e
# generate_indexes.sh - Generate packages.adb for all architectures and feeds
# ssh-keygen -p -m PEM -f id_rsa -N "" -P ""
# openssl rsa -in id_rsa -pubout -out repo.pub

PACKAGES_DIR="${1:-bin}"
echo "Scanning: $PACKAGES_DIR"

find "$PACKAGES_DIR" -maxdepth 4 -type d | while read -r dir; do
    apks=("$dir"/*.apk)
    if [ ! -e "${apks[0]}" ]; then
        echo "  SKIP (no .apk): $dir"
        continue
    fi

    echo "  Indexing (${#apks[@]} packages): $dir"
    ./staging_dir/host/bin/apk mkndx --allow-untrusted --sign-key ./id_rsa -o "$dir/packages.adb" "${apks[@]}"

    if [ $? -eq 0 ]; then
        echo "  OK: $dir/packages.adb"
    else
        echo "  FAILED: $dir"
    fi
done

echo "Done."