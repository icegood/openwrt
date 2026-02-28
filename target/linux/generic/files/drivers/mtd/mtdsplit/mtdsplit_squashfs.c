/*
 *  Copyright (C) 2013 Felix Fietkau <nbd@nbd.name>
 *  Copyright (C) 2013 Gabor Juhos <juhosg@openwrt.org>
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License version 2 as published
 *  by the Free Software Foundation.
 *
 */

#define pr_fmt(fmt)	KBUILD_MODNAME ": " fmt

#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/magic.h>
#include <linux/mtd/mtd.h>
#include <linux/mtd/partitions.h>
#include <linux/byteorder/generic.h>

#include "mtdsplit.h"

#define ROOTFS_SPLIT_SQUASH "root_squashfs"
#define NPARTS 2

static int
mtdsplit_parse_squashfs(struct mtd_info *master,
			const struct mtd_partition **pparts,
			struct mtd_part_parser_data *data)
{
	struct mtd_partition *part;
	struct mtd_info *parent_mtd;
	size_t part_offset;
	size_t squashfs_len;
	int err;

	err = mtd_get_squashfs_len(master, 0, &squashfs_len);
	if (err) {
		pr_info("mtd_get_squashfs_len no size\n");
		return err;
	}

	parent_mtd = mtd_get_master(master);
	part_offset = mtdpart_get_offset(master);
	pr_info("r/o len: %zX never used: %llX inside master '%s'\n", squashfs_len,
		(unsigned long long)((master->size - squashfs_len)&(parent_mtd->erasesize - 1)),
		master->name);

	part = kzalloc(NPARTS * sizeof(*part), GFP_KERNEL);
	if (!part) {
		pr_alert("unable to allocate memory for \"%s\" partition\n", ROOTFS_SPLIT_NAME);
		return -ENOMEM;
	}

	size_t aligned_offset = 
		mtd_roundup_to_eb(part_offset + squashfs_len, parent_mtd) - part_offset;

	part[0].name = ROOTFS_SPLIT_SQUASH;
	part[0].offset = 0;
	part[0].size = aligned_offset;

	part[1].name = ROOTFS_SPLIT_NAME;
	part[1].offset = aligned_offset;
	part[1].size = MTDPART_SIZ_FULL;

	*pparts = part;
	return NPARTS;
}

static struct mtd_part_parser mtdsplit_squashfs_parser = {
	.owner = THIS_MODULE,
	.name = "squashfs-split",
	.parse_fn = mtdsplit_parse_squashfs,
	.type = MTD_PARSER_TYPE_ROOTFS,
};

static int __init mtdsplit_squashfs_init(void)
{
	register_mtd_parser(&mtdsplit_squashfs_parser);

	return 0;
}

subsys_initcall(mtdsplit_squashfs_init);
