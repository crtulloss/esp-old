// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;

/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

	for (i = 0; i < num_windows*tsamps_perbatch*batches_perload*window_size; i++)
		for (j = 0; j < num_windows*hiddens_perwin*window_size; j++)
			if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
				errors++;

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	int j;

	for (i = 0; i < num_windows*tsamps_perbatch*batches_perload*window_size; i++)
		for (j = 0; j < num_loads*num_windows*tsamps_perbatch*batches_perload*window_size; j++)
			in[i * in_words_adj + j] = (token_t) j;

	for (i = 0; i < num_windows*tsamps_perbatch*batches_perload*window_size; i++)
		for (j = 0; j < num_windows*hiddens_perwin*window_size; j++)
			gold[i * out_words_adj + j] = (token_t) j;
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = num_loads*num_windows*tsamps_perbatch*batches_perload*window_size;
		out_words_adj = num_windows*hiddens_perwin*window_size;
	} else {
		in_words_adj = round_up(num_loads*num_windows*tsamps_perbatch*batches_perload*window_size, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(num_windows*hiddens_perwin*window_size, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (num_windows*tsamps_perbatch*batches_perload*window_size);
	out_len =  out_words_adj * (num_windows*tsamps_perbatch*batches_perload*window_size);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = in_len;
	size = (out_offset * sizeof(token_t)) + out_size;
}


int main(int argc, char **argv)
{
	int errors;

	token_t *gold;
	token_t *buf;

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	cfg_000[0].hw_buf = buf;
    
	gold = malloc(out_size);

	init_buffer(buf, gold);

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .hiddens_perwin = %d\n", hiddens_perwin);
	printf("  .window_size = %d\n", window_size);
	printf("  .rate_variance = %d\n", rate_variance);
	printf("  .do_init = %d\n", do_init);
	printf("  .do_backprop = %d\n", do_backprop);
	printf("  .iters_perbatch = %d\n", iters_perbatch);
	printf("  .learning_rate = %d\n", learning_rate);
	printf("  .tsamps_perbatch = %d\n", tsamps_perbatch);
	printf("  .rate_mean = %d\n", rate_mean);
	printf("  .batches_perload = %d\n", batches_perload);
	printf("  .do_thresh_update = %d\n", do_thresh_update);
	printf("  .num_windows = %d\n", num_windows);
	printf("  .num_loads = %d\n", num_loads);
	printf("\n  ** START **\n");

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	free(gold);
	esp_free(buf);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
