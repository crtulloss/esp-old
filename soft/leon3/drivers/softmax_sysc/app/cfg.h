#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef int64_t token_t;

/* <<--params-def-->> */
#define BATCH 1

/* <<--params-->> */
const int32_t batch = BATCH;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "softmax_sysc.0",
		.type = softmax_sysc,
		/* <<--descriptor-->> */
		.desc.softmax_sysc_desc.batch = BATCH,
		.desc.softmax_sysc_desc.src_offset = 0,
		.desc.softmax_sysc_desc.dst_offset = 0,
		.desc.softmax_sysc_desc.esp.coherence = ACC_COH_NONE,
		.desc.softmax_sysc_desc.esp.p2p_store = 0,
		.desc.softmax_sysc_desc.esp.p2p_nsrcs = 0,
		.desc.softmax_sysc_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
