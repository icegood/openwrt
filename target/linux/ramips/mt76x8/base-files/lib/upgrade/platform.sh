#
# Copyright (C) 2010 OpenWrt.org
#

PART_NAME=firmware

platform_check_image() {
	return 0
}

platform_do_upgrade() {
	local board=$(board_name)

	default_do_upgrade "$1"
}
