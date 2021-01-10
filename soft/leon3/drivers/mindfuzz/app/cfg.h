#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define HIDDENS_PERWIN 4
#define WINDOW_SIZE 4
#define RATE_VARIANCE 0.1
#define DO_INIT 1
#define DO_BACKPROP 1
#define ITERS_PERBATCH 1
#define LEARNING_RATE 0.1
#define TSAMPS_PERBATCH 64
#define RATE_MEAN 0.1
#define BATCHES_PERLOAD 1
#define DO_THRESH_UPDATE 1
#define NUM_WINDOWS 1
#define NUM_LOADS 512

/* <<--params-->> */
const int32_t hiddens_perwin = HIDDENS_PERWIN;
const int32_t window_size = WINDOW_SIZE;
const int32_t rate_variance = RATE_VARIANCE;
const int32_t do_init = DO_INIT;
const int32_t do_backprop = DO_BACKPROP;
const int32_t iters_perbatch = ITERS_PERBATCH;
const int32_t learning_rate = LEARNING_RATE;
const int32_t tsamps_perbatch = TSAMPS_PERBATCH;
const int32_t rate_mean = RATE_MEAN;
const int32_t batches_perload = BATCHES_PERLOAD;
const int32_t do_thresh_update = DO_THRESH_UPDATE;
const int32_t num_windows = NUM_WINDOWS;
const int32_t num_loads = NUM_LOADS;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "mindfuzz.0",
		.type = mindfuzz,
		/* <<--descriptor-->> */
		.desc.mindfuzz_desc.hiddens_perwin = HIDDENS_PERWIN,
		.desc.mindfuzz_desc.window_size = WINDOW_SIZE,
		.desc.mindfuzz_desc.rate_variance = RATE_VARIANCE,
		.desc.mindfuzz_desc.do_init = DO_INIT,
		.desc.mindfuzz_desc.do_backprop = DO_BACKPROP,
		.desc.mindfuzz_desc.iters_perbatch = ITERS_PERBATCH,
		.desc.mindfuzz_desc.learning_rate = LEARNING_RATE,
		.desc.mindfuzz_desc.tsamps_perbatch = TSAMPS_PERBATCH,
		.desc.mindfuzz_desc.rate_mean = RATE_MEAN,
		.desc.mindfuzz_desc.batches_perload = BATCHES_PERLOAD,
		.desc.mindfuzz_desc.do_thresh_update = DO_THRESH_UPDATE,
		.desc.mindfuzz_desc.num_windows = NUM_WINDOWS,
		.desc.mindfuzz_desc.num_loads = NUM_LOADS,
		.desc.mindfuzz_desc.src_offset = 0,
		.desc.mindfuzz_desc.dst_offset = 0,
		.desc.mindfuzz_desc.esp.coherence = ACC_COH_NONE,
		.desc.mindfuzz_desc.esp.p2p_store = 0,
		.desc.mindfuzz_desc.esp.p2p_nsrcs = 0,
		.desc.mindfuzz_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
