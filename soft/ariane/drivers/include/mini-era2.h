#ifndef _MINI_ERA_H_
#define _MINI_ERA_H_

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

struct vitdodec_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned cbps;
	unsigned ntraceback;
	unsigned data_bits;
	unsigned src_offset;
	unsigned dst_offset;
};

#define VITDODEC_IOC_ACCESS	_IOW ('S', 0, struct vitdodec_access)


/* <<--params-def-->> */
#define FFTHW_LEN      16384
#define FFTHW_LOG_LEN     14

/* <<--params-->> */
//const int32_t fftHW_len = FFTHW_LEN;
//const int32_t fftHW_log_len = FFTHW_LOG_LEN;

struct fftHW_access {
	struct esp_access esp;
        /* <<--regs-->> */
        unsigned len;
        unsigned log_len;
        unsigned src_offset;
        unsigned dst_offset;
};

#define FFTHW_IOC_ACCESS	_IOW ('S', 0, struct fftHW_access)


#endif /* _MINI_ERA_H_ */
