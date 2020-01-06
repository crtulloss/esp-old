#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef uint8_t /* <<--token-type-->> */ token_t;

/* <<--params-def-->> */

/* <<--params-->> */

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "vitdecoder.0",
		.type = vitdecoder,
		/* <<--descriptor-->> */
		.desc.vitdecoder_desc.src_offset = 0,
		.desc.vitdecoder_desc.dst_offset = 0,
		.desc.vitdecoder_desc.esp.coherence = ACC_COH_NONE,
		.desc.vitdecoder_desc.esp.p2p_store = 0,
		.desc.vitdecoder_desc.esp.p2p_nsrcs = 0,
		.desc.vitdecoder_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
