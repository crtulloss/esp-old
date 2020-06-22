#include "libesp.h"
#include "cfg.h"

#include <sys/time.h>

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size_bytes;

float abs_float(const float input)
{
    return input < 0 ? -input : input;
}


float allowed_error = 0.001;


// TODO when running on Linux use <math.h> exp.
// Returns approximate value of e^x,
// using sum of first n terms of Taylor Series
#if 0
static float exponential(int n, float x)
{
    float sum = 1.0f; // initialize sum of series
    int i;
    for (i = n - 1; i > 0; --i )
        sum = 1 + x * sum / i;

    return sum;
}
#endif

static void softmax_sw(float *input, float *output)
{
    float exp_in[size];
    float sum_exp = 0;
    unsigned i;
    for (i = 0; i < size; i++) {
#if 0
        exp_in[i] = exponential(100, input[i]);
#else
        exp_in[i] = exp(input[i]);
#endif
        sum_exp += exp_in[i];
    }
    for (i = 0; i < size; i++) {
        output[i] = exp_in[i] / sum_exp;
    }
}


/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{
    int i;
    int j;
    unsigned errors = 0;

    for (i = 0; i < batch; i++)
    {
        float in_local_gold[size];
        float out_local_gold[size];

        for (j = 0; j < size; j++)
        {
            in_local_gold[i * size + j] = ((i * size + j) % 32) + 0.25;
        }

        softmax_sw(in_local_gold, out_local_gold);

        for (j = 0; j < size; j++)
        {
            token_t gold_data_fxd = gold[i * out_words_adj + j];
            token_t out_data_fxd = out[i * out_words_adj + j];
            float gold_data_flt = fixed32_to_float(gold_data_fxd, 2);
            float out_data_flt = fixed32_to_float(out_data_fxd, 2);
            float error_it = abs_float(gold_data_flt - out_data_flt);

            if (error_it > allowed_error)
            {
                errors++;
            }
            //printf("INFO: [%d] softmax(%f) = %f (expected %f, error %f %s)\n", i*size+j, in_local_gold[i*size+j], out_data_flt, gold_data_flt, error_it, (error_it > allowed_error)?": ERROR":"");
        }
    }

    return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
    int i;
    int j;

    /* Init input */
    for (i = 0; i < batch; i++)
    {
        for (j = 0; j < size; j++)
        {
            float data_flt = ((i * size + j) % 32) + 0.25;
            token_t data_fxd = 0xdeadbeef00000000 | float_to_fixed32(data_flt, 6);
            in[i * in_words_adj + j] = (token_t) data_fxd;
            /*printf("%s: input[%u] = %lX (%f)\n", __func__, i * size + j, data_fxd, data_flt);*/
        }
    }

    /* Compute golden output */
    for (i = 0; i < batch; i++)
    {
        float in_local_gold[size];
        float out_local_gold[size];

        for (j = 0; j < size; j++)
        {
            in_local_gold[i * size + j] = ((i * size + j) % 32) + 0.25;
        }
    
        softmax_sw(in_local_gold, out_local_gold);

        for (j = 0; j < size; j++)
        {
            float data_flt = out_local_gold[i * size + j];
            token_t data_fxd = float_to_fixed32(data_flt, 2);
            gold[i * out_words_adj + j] = 0xdeadbeef00000000 | (token_t) data_fxd;
            /*printf("%s: gold_output[%u] = %lX (%f)\n", __func__, i * size + j, gold[i * out_words_adj + j], data_flt);*/
        }
    }
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 128 * batch;
		out_words_adj = 128 * batch;
	} else {
		in_words_adj = round_up(128 * batch, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(128 * batch, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj;// * (128);
    /*printf("%s: in_len = %u\n", __func__, in_len);*/
	out_len =  out_words_adj;// * (128);
    /*printf("%s: out_len = %u\n", __func__, out_len);*/
    in_size = in_len * sizeof(token_t);
    /*printf("%s: in_size = %u\n", __func__, in_size);*/
	out_size = out_len * sizeof(token_t);
    /*printf("%s: out_size = %u\n", __func__, out_size);*/
    out_offset = in_len;
    /*printf("%s: out_offset = %u\n", __func__, out_offset);*/
	size_bytes = (out_offset * sizeof(token_t)) + out_size;
    /*printf("%s: size = %u\n", __func__, size);*/
}


int main(int argc, char **argv)
{
	unsigned errors_0 = 0;
	unsigned errors_1 = 0;

	token_t *gold;
	token_t *buf_0;
	token_t *buf_1;

	init_parameters();

	buf_0 = (token_t *) esp_alloc(size_bytes);
    cfg_000[0].hw_buf = buf_0;

    buf_1 = (token_t *) esp_alloc(size_bytes);
    cfg_001[0].hw_buf = buf_1;

    gold = malloc(out_size);

	init_buffer(buf_0, gold);
	init_buffer(buf_1, gold);

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .batch = %d\n", batch);
	printf("\n  ** START **\n");

    struct timeval  hw_begin_0, hw_end_0;
    gettimeofday(&hw_begin_0, NULL);
	esp_run(cfg_000, NACC);
    gettimeofday(&hw_end_0, NULL);

	printf("\n  ** DONE **\n");

	errors_0 = validate_buffer(&buf_0[out_offset], gold);

	//free(gold);
	esp_free(buf_0);

	if (!errors_0)
		printf("  + TEST PASS\n");
	else
		printf("  + TEST FAIL\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

    printf("\n====== %s ======\n\n", cfg_001[0].devname);
	/* <<--print-params-->> */
	printf("  .batch = %d\n", batch);
	printf("\n  ** START **\n");

    struct timeval  hw_begin_1, hw_end_1;
    gettimeofday(&hw_begin_1, NULL);
	esp_run(cfg_001, NACC);
    gettimeofday(&hw_end_1, NULL);

	printf("\n  ** DONE **\n");

	errors_1 = validate_buffer(&buf_1[out_offset], gold);

	free(gold);
	esp_free(buf_1);

	if (!errors_1)
		printf("  + TEST PASS\n");
	else
		printf("  + TEST FAIL\n");

	printf("\n====== %s ======\n\n", cfg_001[0].devname);


    // Profiling results
    {
        unsigned i, j;

        struct timeval  sw_begin, sw_end;
        gettimeofday(&sw_begin, NULL);
        for (i = 0; i < batch; i++)
        {
            float in_local_gold[size];
            float out_local_gold[size];

            for (j = 0; j < size; j++)
            {
                in_local_gold[i * size + j] = ((i * size + j) % 32) + 0.25;
            }
            softmax_sw(in_local_gold, out_local_gold);
        }
        gettimeofday(&sw_end, NULL);

        printf("Software total time = %f seconds\n",
                (double) (sw_end.tv_usec - sw_begin.tv_usec) / 1000000 +
                (double) (sw_end.tv_sec - sw_begin.tv_sec));

        printf("Hardware (%s) total time = %f seconds\n",
                cfg_000[0].devname,
                (double) (hw_end_0.tv_usec - hw_begin_0.tv_usec) / 1000000 +
                (double) (hw_end_0.tv_sec - hw_begin_0.tv_sec));

        printf("Hardware (%s) total time = %f seconds\n",
                cfg_001[0].devname,
                (double) (hw_end_1.tv_usec - hw_begin_1.tv_usec) / 1000000 +
                (double) (hw_end_1.tv_sec - hw_begin_1.tv_sec));
    }

	return (errors_0 + errors_1);
}
