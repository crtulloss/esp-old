#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define BATCH 1

/* <<--params-->> */
const int32_t batch = BATCH;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "softmax_cxx.0",
		.type = softmax_cxx,
		/* <<--descriptor-->> */
		.desc.softmax_cxx_desc.batch = BATCH,
		.desc.softmax_cxx_desc.src_offset = 0,
		.desc.softmax_cxx_desc.dst_offset = 0,
		.desc.softmax_cxx_desc.esp.coherence = ACC_COH_NONE,
		.desc.softmax_cxx_desc.esp.p2p_store = 0,
		.desc.softmax_cxx_desc.esp.p2p_nsrcs = 0,
		.desc.softmax_cxx_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
