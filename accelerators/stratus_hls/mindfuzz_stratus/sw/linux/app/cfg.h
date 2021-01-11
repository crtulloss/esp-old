// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "mindfuzz_stratus.h"

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

struct mindfuzz_stratus_access mindfuzz_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.hiddens_perwin = HIDDENS_PERWIN,
		.window_size = WINDOW_SIZE,
		.rate_variance = RATE_VARIANCE,
		.do_init = DO_INIT,
		.do_backprop = DO_BACKPROP,
		.iters_perbatch = ITERS_PERBATCH,
		.learning_rate = LEARNING_RATE,
		.tsamps_perbatch = TSAMPS_PERBATCH,
		.rate_mean = RATE_MEAN,
		.batches_perload = BATCHES_PERLOAD,
		.do_thresh_update = DO_THRESH_UPDATE,
		.num_windows = NUM_WINDOWS,
		.num_loads = NUM_LOADS,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
	}
};

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "mindfuzz_stratus.0",
		.ioctl_req = MINDFUZZ_STRATUS_IOC_ACCESS,
		.esp_desc = &(mindfuzz_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
