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

	for (i = 0; i < 1 /* <<--number of transfers-->> */; i++)
		for (j = 0; j < 18585 /* <<--data_out_size-->> */; j++)
			if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
				errors++;

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	int j;

	for (i = 0; i < 1 /* <<--number of transfers-->> */; i++)
		for (j = 0; j < 24852 /* <<--data_in_size-->> */; j++)
			in[i * in_words_adj + j] = (token_t) j;

	for (i = 0; i < 1 /* <<--number of transfers-->> */; i++)
		for (j = 0; j < 18585 /* <<--data_out_size-->> */; j++)
			gold[i * out_words_adj + j] = (token_t) j;
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 24852;
		out_words_adj = 18585;
	} else {
		in_words_adj  = round_up(24852 /* <<--data_in_size-->> */, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(18585 /* <<--data_out_size-->> */, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1 /* <<--number of transfers-->> */);
	out_len =  out_words_adj * (1 /* <<--number of transfers-->> */);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = 0 /* <<--store-offset-->> */;
	size = (out_offset * sizeof(token_t)) + out_size;
}


int main(int argc, char **argv)
{
	int errors;

	token_t *gold;
	token_t *buf;

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	gold = malloc(out_size);

	init_buffer(buf, gold);

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("\n  ** START **\n");

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	free(gold);
	esp_cleanup();

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
