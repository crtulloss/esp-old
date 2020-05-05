/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __riscv
#include <stdio.h>
#include <stdlib.h>
#endif

#include <fixed_point.h>
#include <math.h>

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef int64_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define SLD_SOFTMAX 0x050
#define DEV_NAME "sld,softmax"

/* <<--params-->> */
const int32_t size = 128;
const int32_t batch = 1;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define SOFTMAX_SIZE_REG 0x44
#define SOFTMAX_BATCH_REG 0x40

float abs_float(const float input)
{
    return input < 0 ? -input : input;
}

float allowed_error = 0.001;

static int validate_buf(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

#ifndef __riscv
	printf("  gold output data @%p\n", gold);
	printf("       output data @%p\n", out);
#else
	print_uart("  gold output data @"); print_uart_addr((uintptr_t) gold); print_uart("\n");
	print_uart("       output data @"); print_uart_addr((uintptr_t) out); print_uart("\n");
#endif

	for (i = 0; i < 1; i++) {
		for (j = 0; j < size; j++)
        {
            token_t gold_data_fxd = gold[i * out_words_adj + j];
            token_t out_data_fxd = out[i * out_words_adj + j];
#ifdef __riscv
            print_uart("  gold: "); print_uart_int64(gold_data_fxd); print_uart("\n");
            print_uart("  out : "); print_uart_int64(out_data_fxd); print_uart("\n");
#endif
            float gold_data_flt = fixed32_to_float(gold_data_fxd, 2);
            float out_data_flt = fixed32_to_float(out_data_fxd, 2);
            float error_it = abs_float(gold_data_flt - out_data_flt);

			if (error_it > allowed_error)
            {
                print_uart(" ---> ERROR\n");
				errors++;
            }
        }
    }

	return errors;
}

// Returns approximate value of e^x,
// using sum of first n terms of Taylor Series  
static float exponential(int n, float x)  
{
    float sum = 1.0f; // initialize sum of series
    int i;
    for (i = n - 1; i > 0; --i )
        sum = 1 + x * sum / i;  
                    
    return sum;  
}  


static void softmax_sw(float *input, float *output)
{
    float exp_in[size];
    float sum_exp = 0;
    unsigned i;
    for (i = 0; i < size; i++) {
        exp_in[i] = exponential(10, input[i]);
        sum_exp += exp_in[i];
    }
    for (i = 0; i < size; i++) {
        output[i] = exp_in[i] / sum_exp;
    }
}


static void init_buf (token_t *in, token_t * gold)
{
	int i;
	int j;

#ifndef __riscv
	printf("  input data @%p\n", in);
#else
	print_uart("       input  data @"); print_uart_addr((uintptr_t) in); print_uart("\n");
#endif

	for (i = 0; i < 1; i++)
    {
		for (j = 0; j < size; j++)
        {
            float data_flt = ((i * size + j) % 32) + 0.25;
            token_t data_fxd = 0xdeadbeef00000000 | float_to_fixed32(data_flt, 6);
			in[i * in_words_adj + j] = (token_t) data_fxd;
        }
    }

    float in_local_gold[size];
    float out_local_gold[size];
	for (i = 0; i < 1; i++)
    {
		for (j = 0; j < size; j++)
        {
			in_local_gold[i * size + j] = ((i * size + j) % 32) + 0.25;
        }
    }
    softmax_sw(in_local_gold, out_local_gold);

#ifndef __riscv
	printf("  gold output data @%p\n", gold);
#else
	print_uart("  gold output data @"); print_uart_addr((uintptr_t) gold); print_uart("\n");
#endif

    for (i = 0; i < 1; i++) {
		for (j = 0; j < size; j++) {
            float data_flt = out_local_gold[i * size + j];
            token_t data_fxd = float_to_fixed32(data_flt, 2);
			gold[i * out_words_adj + j] = 0xdeadbeef00000000 | (token_t) data_fxd;
            //print_uart("  INIT: gold: "); print_uart_int64(gold[i * out_words_adj + j]); print_uart("\n");
        }
    }
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	unsigned **ptable;
	token_t *mem;
	token_t *gold;
	unsigned errors = 0;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = size;
		out_words_adj = size;
	} else {
		in_words_adj = round_up(size, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(size, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;


	// Search for the device
#ifndef __riscv
	printf("Scanning device tree... \n");
#else
	print_uart("Scanning device tree... \n");
#endif

	ndev = probe(&espdevs, SLD_SOFTMAX, DEV_NAME);
	if (ndev == 0) {
#ifndef __riscv
		printf("softmax not found\n");
#else
		print_uart("softmax not found\n");
#endif
		return 0;
	}

	for (n = 0; n < ndev; n++) {

		dev = &espdevs[n];

		// Check DMA capabilities
		if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
#ifndef __riscv
			printf("  -> scatter-gather DMA is disabled. Abort.\n");
#else
			print_uart("  -> scatter-gather DMA is disabled. Abort.\n");
#endif
			return 0;
		}

		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
#ifndef __riscv
			printf("  -> Not enough TLB entries available. Abort.\n");
#else
			print_uart("  -> Not enough TLB entries available. Abort.\n");
#endif
			return 0;
		}

		// Allocate memory
		gold = aligned_malloc(out_size);
		mem = aligned_malloc(mem_size);
#ifndef __riscv
		printf("  memory buffer base-address = %p\n", mem);
#else
		print_uart("  memory buffer base-address = "); print_uart_addr((uintptr_t) mem); print_uart("\n");
#endif
		// Alocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
#ifndef __riscv
		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));
#else
		print_uart("  ptable = "); print_uart_addr((uintptr_t) ptable); print_uart("\n");
		print_uart("  nchunk = "); print_uart_int(NCHUNK(mem_size)); print_uart("\n");
#endif

#ifndef __riscv
		printf("  Generate input...\n");
#else
		print_uart("  Generate input...\n");
#endif
 
        init_buf(mem, gold);

		// Pass common configuration parameters

		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

#ifndef __sparc
		iowrite32(dev, PT_ADDRESS_REG, (unsigned long long) ptable);
#else
		iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
#endif
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		//iowrite32(dev, SRC_OFFSET_REG, 0x0);
		//iowrite32(dev, DST_OFFSET_REG, 0x0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
		iowrite32(dev, SOFTMAX_SIZE_REG, size);
		iowrite32(dev, SOFTMAX_BATCH_REG, batch);

		// Flush (customize coherence model here)
		esp_flush(ACC_COH_NONE);

		// Start accelerators
#ifndef __riscv
		printf("  Start...\n");
#else
		print_uart("  Start...\n");
#endif

		iowrite32(dev, CMD_REG, CMD_MASK_START);

        // Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}
		iowrite32(dev, CMD_REG, 0x0);

#ifndef __riscv
		printf("  Done\n");
		printf("  validating...\n");
#else
		print_uart("  Done\n");
		print_uart("  validating...\n");
#endif

		/* Validation */
		errors = validate_buf(&mem[out_offset], gold);
#ifndef __riscv
		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");
#else
		if (errors)
			print_uart("  ... FAIL\n");
		else
			print_uart("  ... PASS\n");
#endif

		aligned_free(ptable);
		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
