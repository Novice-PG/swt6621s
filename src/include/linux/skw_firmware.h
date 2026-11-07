/* SPDX-License-Identifier: GPL-2.0 */
#ifndef __SKW_FIRMWARE_H__
#define __SKW_FIRMWARE_H__

#include <linux/errno.h>
#include <linux/firmware.h>
#include <linux/kernel.h>
#include <linux/of.h>
#include <linux/slab.h>
#include <linux/string.h>

typedef int (*skw_firmware_loader)(const struct firmware **fw,
				   const char *name, struct device *dev);

static inline bool skw_firmware_relative_path(const char *path)
{
	const char *end;

	if (*path == '/')
		return false;

	while (*path) {
		end = strchrnul(path, '/');
		if (end - path == 2 && path[0] == '.' && path[1] == '.')
			return false;
		if (!*end)
			break;
		path = end + 1;
	}

	return true;
}

/*
 * Try <directory>/<name>.<root-compatible>.<extension> before the generic
 * filename. An empty directory retains the standard firmware search paths.
 * The caller selects the loader for the generic file; the optional
 * board-specific lookup never invokes the userspace firmware fallback.
 */
static inline int skw_firmware_request(const struct firmware **fw,
		const char *name, struct device *dev, const char *directory,
		skw_firmware_loader load)
{
	struct device_node *root;
	const char *board, *base, *dot;
	char *full_name, *board_name;
	int ret;

	*fw = NULL;
	if (!name || !*name || !skw_firmware_relative_path(name) ||
	    (directory && !skw_firmware_relative_path(directory)))
		return -EINVAL;

	if (directory && *directory)
		full_name = kasprintf(GFP_KERNEL, "%s/%s", directory, name);
	else
		full_name = kstrdup(name, GFP_KERNEL);
	if (!full_name)
		return -ENOMEM;

	root = of_find_node_by_path("/");
	if (root && !of_property_read_string(root, "compatible", &board) &&
	    *board && !strchr(board, '/') && strcmp(board, ".") &&
	    strcmp(board, "..")) {
		base = strrchr(full_name, '/');
		base = base ? base + 1 : full_name;
		dot = strrchr(base, '.');
		if (!dot || dot == base)
			dot = full_name + strlen(full_name);

		board_name = kasprintf(GFP_KERNEL, "%.*s.%s%s",
				      (int)(dot - full_name), full_name, board, dot);
		if (!board_name) {
			ret = -ENOMEM;
			goto out;
		}

		ret = request_firmware_direct(fw, board_name, dev);
		if (!ret)
			pr_info("skw firmware: loaded %s\n", board_name);
		kfree(board_name);
		if (ret != -ENOENT)
			goto out;
	}

	ret = load(fw, full_name, dev);
	if (!ret)
		pr_info("skw firmware: loaded %s\n", full_name);
out:
	of_node_put(root);
	kfree(full_name);
	return ret;
}

#endif /* __SKW_FIRMWARE_H__ */
