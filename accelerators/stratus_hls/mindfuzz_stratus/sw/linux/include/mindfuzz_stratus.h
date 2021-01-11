// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _MINDFUZZ_STRATUS_H_
#define _MINDFUZZ_STRATUS_H_

#ifdef __KERNEL__
#include <linux/ioctl.h>
#include <linux/types.h>
#else
#include <sys/ioctl.h>
#include <stdint.h>
#ifndef __user
#define __user
#endif
#endif /* __KERNEL__ */

#include <esp.h>
#include <esp_accelerator.h>

struct mindfuzz_stratus_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned hiddens_perwin;
	unsigned window_size;
	unsigned rate_variance;
	unsigned do_init;
	unsigned do_backprop;
	unsigned iters_perbatch;
	unsigned learning_rate;
	unsigned tsamps_perbatch;
	unsigned rate_mean;
	unsigned batches_perload;
	unsigned do_thresh_update;
	unsigned num_windows;
	unsigned num_loads;
	unsigned src_offset;
	unsigned dst_offset;
};

#define MINDFUZZ_STRATUS_IOC_ACCESS	_IOW ('S', 0, struct mindfuzz_stratus_access)

#endif /* _MINDFUZZ_STRATUS_H_ */
