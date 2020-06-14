#ifndef _SOFTMAX_SYSC_H_
#define _SOFTMAX_SYSC_H_

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

struct softmax_sysc_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned size;
	unsigned batch;
	unsigned src_offset;
	unsigned dst_offset;
};

#define SOFTMAX_SYSC_IOC_ACCESS	_IOW ('S', 0, struct softmax_sysc_access)

#endif /* _SOFTMAX_SYSC_H_ */
