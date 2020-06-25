#ifndef __TESTS_H__
#define __TESTS_H__

#include "sha2.h"
#include "utils.h"

/* SHA3BYTE Monte Carlo Test Vectors */

#define SHA224_MONTECARLO_VERBOSE 0
#define SHA256_MONTECARLO_VERBOSE 0
#define SHA384_MONTECARLO_VERBOSE 0
#define SHA512_MONTECARLO_VERBOSE 0

/* SHA3BYTE Short Message (ShortMsg) Test Vectors */

#define SHA224_SHORTMSG_VERBOSE 0
#define SHA256_SHORTMSG_VERBOSE 0
#define SHA384_SHORTMSG_VERBOSE 0
#define SHA512_SHORTMSG_VERBOSE 0

/* SHA3BYTE Long Message (LongMsg) Test Vectors */

#define SHA224_LONGMSG_VERBOSE 0
#define SHA256_LONGMSG_VERBOSE 0
#define SHA384_LONGMSG_VERBOSE 0
#define SHA512_LONGMSG_VERBOSE 0

/*****************************************************************************/

int sha224_montecarlo(void)
{
    uint8_t *buffer_in0;
    uint8_t *buffer_in1;
    uint8_t *buffer_in2;
    uint8_t *buffer_in3;
    uint8_t *buffer_out;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer_in0 = (uint8_t *) malloc(sizeof(uint8_t) * 224 / 8);
    buffer_in1 = (uint8_t *) malloc(sizeof(uint8_t) * 224 / 8);
    buffer_in2 = (uint8_t *) malloc(sizeof(uint8_t) * 224 / 8);
    buffer_in3 = (uint8_t *) malloc(3 * sizeof(uint8_t) * 224 / 8);
    buffer_out = (uint8_t *) malloc(sizeof(uint8_t) * 224 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA224Monte.rsp", SHA_MONTECARLO);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA224Monte.rsp", SHA_MONTECARLO);
#endif

    ESP_REPORT_INFO(VON, "Total tests: %u", cavp.tot_tests);

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VON, "Run test # %u", t);

        memcpy(buffer_in0, cavp.s, sizeof(uint8_t) * 224 / 8);
        memcpy(buffer_in1, cavp.s, sizeof(uint8_t) * 224 / 8);
        memcpy(buffer_in2, cavp.s, sizeof(uint8_t) * 224 / 8);

        for (unsigned j = 3; j < 1003; ++j)
        {
            ESP_REPORT_INFO(VON, "Run test # %u.%u", t, j);

            for (unsigned k = 0; k < 224 / 8; ++k)
            {
                // Concatenate buffer_in0, in1 and in2
                buffer_in3[k + 0      ] = buffer_in0[k];
                buffer_in3[k + 224 / 8] = buffer_in1[k];
                buffer_in3[k + 224 / 4] = buffer_in2[k];
            }

            const unsigned sha2_in_bytes = 3 * 224 / 8;
            const unsigned sha2_out_bytes = 224 / 8;
            const unsigned sha2_batch = 1;

            // Accelerator configuration
            ac_channel<conf_info_t> conf_info;

            conf_info_t conf_info_data;
            conf_info_data.batch = sha2_batch;
            conf_info_data.in_bytes = sha2_in_bytes;
            conf_info_data.out_bytes = sha2_out_bytes;

            // Communication channels
            ac_channel<dma_info_t> dma_read_ctrl;
            ac_channel<dma_info_t> dma_write_ctrl;
            ac_channel<dma_data_t> dma_read_chnl;
            ac_channel<dma_data_t> dma_write_chnl;

            // Accelerator done (workaround)
            ac_sync acc_done;

            // Testbench data
            data_t inputs[PLM_IN_SIZE * BATCH_MAX];
            data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
            data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

            ESP_REPORT_INFO(VOFF, "Configuration:");
            ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
            ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
            ESP_REPORT_INFO(VOFF, "Other info:");
            ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
            ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
            ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
            ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
            ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
            ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "---------------------------------------");

            // Pass inputs to the accelerator
            for (unsigned b = 0; b < sha2_batch; b++) {
               for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                    data_t d0 = (i+0 < sha2_in_bytes) ? buffer_in3[i+0] : data_t(0);
                    data_t d1 = (i+1 < sha2_in_bytes) ? buffer_in3[i+1] : data_t(0);
                    data_t d2 = (i+2 < sha2_in_bytes) ? buffer_in3[i+2] : data_t(0);
                    data_t d3 = (i+3 < sha2_in_bytes) ? buffer_in3[i+3] : data_t(0);
                    data_t d4 = (i+4 < sha2_in_bytes) ? buffer_in3[i+4] : data_t(0);
                    data_t d5 = (i+5 < sha2_in_bytes) ? buffer_in3[i+5] : data_t(0);
                    data_t d6 = (i+6 < sha2_in_bytes) ? buffer_in3[i+6] : data_t(0);
                    data_t d7 = (i+7 < sha2_in_bytes) ? buffer_in3[i+7] : data_t(0);

                    inputs[b * sha2_in_bytes + i+0] = d0;
                    inputs[b * sha2_in_bytes + i+1] = d1;
                    inputs[b * sha2_in_bytes + i+2] = d2;
                    inputs[b * sha2_in_bytes + i+3] = d3;
                    inputs[b * sha2_in_bytes + i+4] = d4;
                    inputs[b * sha2_in_bytes + i+5] = d5;
                    inputs[b * sha2_in_bytes + i+6] = d6;
                    inputs[b * sha2_in_bytes + i+7] = d7;

                    dma_data_t dma_data;
                    dma_data.template set_slc<DATA_WIDTH>(0, d0);
                    dma_data.template set_slc<DATA_WIDTH>(8, d1);
                    dma_data.template set_slc<DATA_WIDTH>(16, d2);
                    dma_data.template set_slc<DATA_WIDTH>(24, d3);
                    dma_data.template set_slc<DATA_WIDTH>(32, d4);
                    dma_data.template set_slc<DATA_WIDTH>(40, d5);
                    dma_data.template set_slc<DATA_WIDTH>(48, d6);
                    dma_data.template set_slc<DATA_WIDTH>(56, d7);

                    dma_read_chnl.write(dma_data);
                }
            }

            // Pass configuration to the accelerator
            conf_info.write(conf_info_data);

            // Run the accelerator
            sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

            unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
            // Fetch outputs from the accelerator
            while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
            for (unsigned b = 0; b < conf_info_data.batch; b++) {
                for (unsigned i = 0; i < conf_info_data.out_bytes; i+=8) {

                    dma_data_t dma_data = dma_write_chnl.read();

                    data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                    data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                    data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                    data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                    data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                    data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                    data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                    data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                    outputs[b * sha2_out_bytes + i+0] = d0;
                    outputs[b * sha2_out_bytes + i+1] = d1;
                    outputs[b * sha2_out_bytes + i+2] = d2;
                    outputs[b * sha2_out_bytes + i+3] = d3;
                    outputs[b * sha2_out_bytes + i+4] = d4;
                    outputs[b * sha2_out_bytes + i+5] = d5;
                    outputs[b * sha2_out_bytes + i+6] = d6;
                    outputs[b * sha2_out_bytes + i+7] = d7;
                }
            }

            for (unsigned i = 0; i < sha2_out_bytes; i++) {
                buffer_out[i] = outputs[i];
            }

            memcpy(buffer_in0, buffer_in1, sizeof(uint8_t) * 224 / 8);
            memcpy(buffer_in1, buffer_in2, sizeof(uint8_t) * 224 / 8);
            memcpy(buffer_in2, buffer_out, sizeof(uint8_t) * 224 / 8);
        }

        // Validation
        test_passed += eval_cavp(&cavp, buffer_out, 224 / 8, t, SHA_MONTECARLO, SHA224_MONTECARLO_VERBOSE);

        memcpy(cavp.s, buffer_out, sizeof(uint8_t) * 224 / 8);
        if (t >= 3) break;
    }

    free_cavp(&cavp, SHA_MONTECARLO);
    free(buffer_in0);
    free(buffer_in1);
    free(buffer_in2);
    free(buffer_in3);
    free(buffer_out);

    return cavp.tot_tests - test_passed;
}


int sha256_montecarlo(void)
{
    uint8_t *buffer_in0;
    uint8_t *buffer_in1;
    uint8_t *buffer_in2;
    uint8_t *buffer_in3;
    uint8_t *buffer_out;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer_in0 = (uint8_t *) malloc(sizeof(uint8_t) * 256 / 8);
    buffer_in1 = (uint8_t *) malloc(sizeof(uint8_t) * 256 / 8);
    buffer_in2 = (uint8_t *) malloc(sizeof(uint8_t) * 256 / 8);
    buffer_in3 = (uint8_t *) malloc(3 * sizeof(uint8_t) * 256 / 8);
    buffer_out = (uint8_t *) malloc(sizeof(uint8_t) * 256 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA256Monte.rsp", SHA_MONTECARLO);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA256Monte.rsp", SHA_MONTECARLO);
#endif

    ESP_REPORT_INFO(VON, "Total tests: %u", cavp.tot_tests);

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VON, "Run test # %u", t);

        memcpy(buffer_in0, cavp.s, sizeof(uint8_t) * 256 / 8);
        memcpy(buffer_in1, cavp.s, sizeof(uint8_t) * 256 / 8);
        memcpy(buffer_in2, cavp.s, sizeof(uint8_t) * 256 / 8);

        for (unsigned j = 3; j < 1003; ++j)
        {
            ESP_REPORT_INFO(VON, "Run test # %u.%u", t, j);

            for (unsigned k = 0; k < 256 / 8; ++k)
            {
                // Concatenate buffer_in0, in1 and in2
                buffer_in3[k + 0      ] = buffer_in0[k];
                buffer_in3[k + 256 / 8] = buffer_in1[k];
                buffer_in3[k + 256 / 4] = buffer_in2[k];
            }

            const unsigned sha2_in_bytes = 3 * 256 / 8;
            const unsigned sha2_out_bytes = 256 / 8;
            const unsigned sha2_batch = 1;

            // Accelerator configuration
            ac_channel<conf_info_t> conf_info;

            conf_info_t conf_info_data;
            conf_info_data.batch = sha2_batch;
            conf_info_data.in_bytes = sha2_in_bytes;
            conf_info_data.out_bytes = sha2_out_bytes;

            // Communication channels
            ac_channel<dma_info_t> dma_read_ctrl;
            ac_channel<dma_info_t> dma_write_ctrl;
            ac_channel<dma_data_t> dma_read_chnl;
            ac_channel<dma_data_t> dma_write_chnl;

            // Accelerator done (workaround)
            ac_sync acc_done;

            // Testbench data
            data_t inputs[PLM_IN_SIZE * BATCH_MAX];
            data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
            data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

            ESP_REPORT_INFO(VOFF, "Configuration:");
            ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
            ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
            ESP_REPORT_INFO(VOFF, "Other info:");
            ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
            ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
            ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
            ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
            ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
            ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "---------------------------------------");

            // Pass inputs to the accelerator
            for (unsigned b = 0; b < sha2_batch; b++) {
               for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                    data_t d0 = (i+0 < sha2_in_bytes) ? buffer_in3[i+0] : data_t(0);
                    data_t d1 = (i+1 < sha2_in_bytes) ? buffer_in3[i+1] : data_t(0);
                    data_t d2 = (i+2 < sha2_in_bytes) ? buffer_in3[i+2] : data_t(0);
                    data_t d3 = (i+3 < sha2_in_bytes) ? buffer_in3[i+3] : data_t(0);
                    data_t d4 = (i+4 < sha2_in_bytes) ? buffer_in3[i+4] : data_t(0);
                    data_t d5 = (i+5 < sha2_in_bytes) ? buffer_in3[i+5] : data_t(0);
                    data_t d6 = (i+6 < sha2_in_bytes) ? buffer_in3[i+6] : data_t(0);
                    data_t d7 = (i+7 < sha2_in_bytes) ? buffer_in3[i+7] : data_t(0);

                    inputs[b * sha2_in_bytes + i+0] = d0;
                    inputs[b * sha2_in_bytes + i+1] = d1;
                    inputs[b * sha2_in_bytes + i+2] = d2;
                    inputs[b * sha2_in_bytes + i+3] = d3;
                    inputs[b * sha2_in_bytes + i+4] = d4;
                    inputs[b * sha2_in_bytes + i+5] = d5;
                    inputs[b * sha2_in_bytes + i+6] = d6;
                    inputs[b * sha2_in_bytes + i+7] = d7;

                    dma_data_t dma_data;
                    dma_data.template set_slc<DATA_WIDTH>(0, d0);
                    dma_data.template set_slc<DATA_WIDTH>(8, d1);
                    dma_data.template set_slc<DATA_WIDTH>(16, d2);
                    dma_data.template set_slc<DATA_WIDTH>(24, d3);
                    dma_data.template set_slc<DATA_WIDTH>(32, d4);
                    dma_data.template set_slc<DATA_WIDTH>(40, d5);
                    dma_data.template set_slc<DATA_WIDTH>(48, d6);
                    dma_data.template set_slc<DATA_WIDTH>(56, d7);

                    dma_read_chnl.write(dma_data);
                }
            }

            // Pass configuration to the accelerator
            conf_info.write(conf_info_data);

            // Run the accelerator
            sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

            unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
            // Fetch outputs from the accelerator
            while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
            for (unsigned b = 0; b < conf_info_data.batch; b++) {
                for (unsigned i = 0; i < conf_info_data.out_bytes; i+=8) {

                    dma_data_t dma_data = dma_write_chnl.read();

                    data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                    data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                    data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                    data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                    data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                    data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                    data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                    data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                    outputs[b * sha2_out_bytes + i+0] = d0;
                    outputs[b * sha2_out_bytes + i+1] = d1;
                    outputs[b * sha2_out_bytes + i+2] = d2;
                    outputs[b * sha2_out_bytes + i+3] = d3;
                    outputs[b * sha2_out_bytes + i+4] = d4;
                    outputs[b * sha2_out_bytes + i+5] = d5;
                    outputs[b * sha2_out_bytes + i+6] = d6;
                    outputs[b * sha2_out_bytes + i+7] = d7;
                }
            }

            for (unsigned i = 0; i < sha2_out_bytes; i++) {
                buffer_out[i] = outputs[i];
            }

            memcpy(buffer_in0, buffer_in1, sizeof(uint8_t) * 256 / 8);
            memcpy(buffer_in1, buffer_in2, sizeof(uint8_t) * 256 / 8);
            memcpy(buffer_in2, buffer_out, sizeof(uint8_t) * 256 / 8);
        }

        // Validation
        test_passed += eval_cavp(&cavp, buffer_out, 256 / 8, t, SHA_MONTECARLO, SHA256_MONTECARLO_VERBOSE);

        memcpy(cavp.s, buffer_out, sizeof(uint8_t) * 256 / 8);
        if (t >= 3) break;
    }

    free_cavp(&cavp, SHA_MONTECARLO);
    free(buffer_in0);
    free(buffer_in1);
    free(buffer_in2);
    free(buffer_in3);
    free(buffer_out);

    return cavp.tot_tests - test_passed;
}

int sha384_montecarlo(void)
{
    uint8_t *buffer_in0;
    uint8_t *buffer_in1;
    uint8_t *buffer_in2;
    uint8_t *buffer_in3;
    uint8_t *buffer_out;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer_in0 = (uint8_t *) malloc(sizeof(uint8_t) * 384 / 8);
    buffer_in1 = (uint8_t *) malloc(sizeof(uint8_t) * 384 / 8);
    buffer_in2 = (uint8_t *) malloc(sizeof(uint8_t) * 384 / 8);
    buffer_in3 = (uint8_t *) malloc(3 * sizeof(uint8_t) * 384 / 8);
    buffer_out = (uint8_t *) malloc(sizeof(uint8_t) * 384 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA384Monte.rsp", SHA_MONTECARLO);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA384Monte.rsp", SHA_MONTECARLO);
#endif

    ESP_REPORT_INFO(VON, "Total tests: %u", cavp.tot_tests);

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VON, "Run test # %u", t);

        memcpy(buffer_in0, cavp.s, sizeof(uint8_t) * 384 / 8);
        memcpy(buffer_in1, cavp.s, sizeof(uint8_t) * 384 / 8);
        memcpy(buffer_in2, cavp.s, sizeof(uint8_t) * 384 / 8);

        for (unsigned j = 3; j < 1003; ++j)
        {
            ESP_REPORT_INFO(VON, "Run test # %u.%u", t, j);

            for (unsigned k = 0; k < 384 / 8; ++k)
            {
                // Concatenate buffer_in0, in1 and in2
                buffer_in3[k + 0      ] = buffer_in0[k];
                buffer_in3[k + 384 / 8] = buffer_in1[k];
                buffer_in3[k + 384 / 4] = buffer_in2[k];
            }

            const unsigned sha2_in_bytes = 3 * 384 / 8;
            const unsigned sha2_out_bytes = 384 / 8;
            const unsigned sha2_batch = 1;

            // Accelerator configuration
            ac_channel<conf_info_t> conf_info;

            conf_info_t conf_info_data;
            conf_info_data.batch = sha2_batch;
            conf_info_data.in_bytes = sha2_in_bytes;
            conf_info_data.out_bytes = sha2_out_bytes;

            // Communication channels
            ac_channel<dma_info_t> dma_read_ctrl;
            ac_channel<dma_info_t> dma_write_ctrl;
            ac_channel<dma_data_t> dma_read_chnl;
            ac_channel<dma_data_t> dma_write_chnl;

            // Accelerator done (workaround)
            ac_sync acc_done;

            // Testbench data
            data_t inputs[PLM_IN_SIZE * BATCH_MAX];
            data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
            data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

            ESP_REPORT_INFO(VOFF, "Configuration:");
            ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
            ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
            ESP_REPORT_INFO(VOFF, "Other info:");
            ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
            ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
            ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
            ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
            ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
            ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "---------------------------------------");

            // Pass inputs to the accelerator
            for (unsigned b = 0; b < sha2_batch; b++) {
               for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                    data_t d0 = (i+0 < sha2_in_bytes) ? buffer_in3[i+0] : data_t(0);
                    data_t d1 = (i+1 < sha2_in_bytes) ? buffer_in3[i+1] : data_t(0);
                    data_t d2 = (i+2 < sha2_in_bytes) ? buffer_in3[i+2] : data_t(0);
                    data_t d3 = (i+3 < sha2_in_bytes) ? buffer_in3[i+3] : data_t(0);
                    data_t d4 = (i+4 < sha2_in_bytes) ? buffer_in3[i+4] : data_t(0);
                    data_t d5 = (i+5 < sha2_in_bytes) ? buffer_in3[i+5] : data_t(0);
                    data_t d6 = (i+6 < sha2_in_bytes) ? buffer_in3[i+6] : data_t(0);
                    data_t d7 = (i+7 < sha2_in_bytes) ? buffer_in3[i+7] : data_t(0);

                    inputs[b * sha2_in_bytes + i+0] = d0;
                    inputs[b * sha2_in_bytes + i+1] = d1;
                    inputs[b * sha2_in_bytes + i+2] = d2;
                    inputs[b * sha2_in_bytes + i+3] = d3;
                    inputs[b * sha2_in_bytes + i+4] = d4;
                    inputs[b * sha2_in_bytes + i+5] = d5;
                    inputs[b * sha2_in_bytes + i+6] = d6;
                    inputs[b * sha2_in_bytes + i+7] = d7;

                    dma_data_t dma_data;
                    dma_data.template set_slc<DATA_WIDTH>(0, d0);
                    dma_data.template set_slc<DATA_WIDTH>(8, d1);
                    dma_data.template set_slc<DATA_WIDTH>(16, d2);
                    dma_data.template set_slc<DATA_WIDTH>(24, d3);
                    dma_data.template set_slc<DATA_WIDTH>(32, d4);
                    dma_data.template set_slc<DATA_WIDTH>(40, d5);
                    dma_data.template set_slc<DATA_WIDTH>(48, d6);
                    dma_data.template set_slc<DATA_WIDTH>(56, d7);

                    dma_read_chnl.write(dma_data);
                }
            }

            // Pass configuration to the accelerator
            conf_info.write(conf_info_data);

            // Run the accelerator
            sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

            unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
            // Fetch outputs from the accelerator
            while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
            for (unsigned b = 0; b < conf_info_data.batch; b++) {
                for (unsigned i = 0; i < conf_info_data.out_bytes; i+=8) {

                    dma_data_t dma_data = dma_write_chnl.read();

                    data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                    data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                    data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                    data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                    data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                    data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                    data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                    data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                    outputs[b * sha2_out_bytes + i+0] = d0;
                    outputs[b * sha2_out_bytes + i+1] = d1;
                    outputs[b * sha2_out_bytes + i+2] = d2;
                    outputs[b * sha2_out_bytes + i+3] = d3;
                    outputs[b * sha2_out_bytes + i+4] = d4;
                    outputs[b * sha2_out_bytes + i+5] = d5;
                    outputs[b * sha2_out_bytes + i+6] = d6;
                    outputs[b * sha2_out_bytes + i+7] = d7;
                }
            }

            for (unsigned i = 0; i < sha2_out_bytes; i++) {
                buffer_out[i] = outputs[i];
            }

            memcpy(buffer_in0, buffer_in1, sizeof(uint8_t) * 384 / 8);
            memcpy(buffer_in1, buffer_in2, sizeof(uint8_t) * 384 / 8);
            memcpy(buffer_in2, buffer_out, sizeof(uint8_t) * 384 / 8);
        }

        // Validation
        test_passed += eval_cavp(&cavp, buffer_out, 384 / 8, t, SHA_MONTECARLO, SHA384_MONTECARLO_VERBOSE);

        memcpy(cavp.s, buffer_out, sizeof(uint8_t) * 384 / 8);
        if (t >= 3) break;
    }

    free_cavp(&cavp, SHA_MONTECARLO);
    free(buffer_in0);
    free(buffer_in1);
    free(buffer_in2);
    free(buffer_in3);
    free(buffer_out);

    return cavp.tot_tests - test_passed;
}

int sha512_montecarlo(void)
{
    uint8_t *buffer_in0;
    uint8_t *buffer_in1;
    uint8_t *buffer_in2;
    uint8_t *buffer_in3;
    uint8_t *buffer_out;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer_in0 = (uint8_t *) malloc(sizeof(uint8_t) * 512 / 8);
    buffer_in1 = (uint8_t *) malloc(sizeof(uint8_t) * 512 / 8);
    buffer_in2 = (uint8_t *) malloc(sizeof(uint8_t) * 512 / 8);
    buffer_in3 = (uint8_t *) malloc(3 * sizeof(uint8_t) * 512 / 8);
    buffer_out = (uint8_t *) malloc(sizeof(uint8_t) * 512 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA512Monte.rsp", SHA_MONTECARLO);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA512Monte.rsp", SHA_MONTECARLO);
#endif

    ESP_REPORT_INFO(VON, "Total tests: %u", cavp.tot_tests);

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VON, "Run test # %u", t);

        memcpy(buffer_in0, cavp.s, sizeof(uint8_t) * 512 / 8);
        memcpy(buffer_in1, cavp.s, sizeof(uint8_t) * 512 / 8);
        memcpy(buffer_in2, cavp.s, sizeof(uint8_t) * 512 / 8);

        for (unsigned j = 3; j < 1003; ++j)
        {
            ESP_REPORT_INFO(VON, "Run test # %u.%u", t, j);

            for (unsigned k = 0; k < 512 / 8; ++k)
            {
                // Concatenate buffer_in0, in1 and in2
                buffer_in3[k + 0      ] = buffer_in0[k];
                buffer_in3[k + 512 / 8] = buffer_in1[k];
                buffer_in3[k + 512 / 4] = buffer_in2[k];
            }

            const unsigned sha2_in_bytes = 3 * 512 / 8;
            const unsigned sha2_out_bytes = 512 / 8;
            const unsigned sha2_batch = 1;

            // Accelerator configuration
            ac_channel<conf_info_t> conf_info;

            conf_info_t conf_info_data;
            conf_info_data.batch = sha2_batch;
            conf_info_data.in_bytes = sha2_in_bytes;
            conf_info_data.out_bytes = sha2_out_bytes;

            // Communication channels
            ac_channel<dma_info_t> dma_read_ctrl;
            ac_channel<dma_info_t> dma_write_ctrl;
            ac_channel<dma_data_t> dma_read_chnl;
            ac_channel<dma_data_t> dma_write_chnl;

            // Accelerator done (workaround)
            ac_sync acc_done;

            // Testbench data
            data_t inputs[PLM_IN_SIZE * BATCH_MAX];
            data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
            data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

            ESP_REPORT_INFO(VOFF, "Configuration:");
            ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
            ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
            ESP_REPORT_INFO(VOFF, "Other info:");
            ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
            ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
            ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
            ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
            ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
            ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
            ESP_REPORT_INFO(VOFF, "---------------------------------------");

            // Pass inputs to the accelerator
            for (unsigned b = 0; b < sha2_batch; b++) {
               for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                    data_t d0 = (i+0 < sha2_in_bytes) ? buffer_in3[i+0] : data_t(0);
                    data_t d1 = (i+1 < sha2_in_bytes) ? buffer_in3[i+1] : data_t(0);
                    data_t d2 = (i+2 < sha2_in_bytes) ? buffer_in3[i+2] : data_t(0);
                    data_t d3 = (i+3 < sha2_in_bytes) ? buffer_in3[i+3] : data_t(0);
                    data_t d4 = (i+4 < sha2_in_bytes) ? buffer_in3[i+4] : data_t(0);
                    data_t d5 = (i+5 < sha2_in_bytes) ? buffer_in3[i+5] : data_t(0);
                    data_t d6 = (i+6 < sha2_in_bytes) ? buffer_in3[i+6] : data_t(0);
                    data_t d7 = (i+7 < sha2_in_bytes) ? buffer_in3[i+7] : data_t(0);

                    inputs[b * sha2_in_bytes + i+0] = d0;
                    inputs[b * sha2_in_bytes + i+1] = d1;
                    inputs[b * sha2_in_bytes + i+2] = d2;
                    inputs[b * sha2_in_bytes + i+3] = d3;
                    inputs[b * sha2_in_bytes + i+4] = d4;
                    inputs[b * sha2_in_bytes + i+5] = d5;
                    inputs[b * sha2_in_bytes + i+6] = d6;
                    inputs[b * sha2_in_bytes + i+7] = d7;

                    dma_data_t dma_data;
                    dma_data.template set_slc<DATA_WIDTH>(0, d0);
                    dma_data.template set_slc<DATA_WIDTH>(8, d1);
                    dma_data.template set_slc<DATA_WIDTH>(16, d2);
                    dma_data.template set_slc<DATA_WIDTH>(24, d3);
                    dma_data.template set_slc<DATA_WIDTH>(32, d4);
                    dma_data.template set_slc<DATA_WIDTH>(40, d5);
                    dma_data.template set_slc<DATA_WIDTH>(48, d6);
                    dma_data.template set_slc<DATA_WIDTH>(56, d7);

                    dma_read_chnl.write(dma_data);
                }
            }

            // Pass configuration to the accelerator
            conf_info.write(conf_info_data);

            // Run the accelerator
            sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

            unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
            // Fetch outputs from the accelerator
            while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
            for (unsigned b = 0; b < conf_info_data.batch; b++) {
                for (unsigned i = 0; i < conf_info_data.out_bytes; i+=8) {

                    dma_data_t dma_data = dma_write_chnl.read();

                    data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                    data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                    data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                    data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                    data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                    data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                    data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                    data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                    outputs[b * sha2_out_bytes + i+0] = d0;
                    outputs[b * sha2_out_bytes + i+1] = d1;
                    outputs[b * sha2_out_bytes + i+2] = d2;
                    outputs[b * sha2_out_bytes + i+3] = d3;
                    outputs[b * sha2_out_bytes + i+4] = d4;
                    outputs[b * sha2_out_bytes + i+5] = d5;
                    outputs[b * sha2_out_bytes + i+6] = d6;
                    outputs[b * sha2_out_bytes + i+7] = d7;
                }
            }

            for (unsigned i = 0; i < sha2_out_bytes; i++) {
                buffer_out[i] = outputs[i];
            }

            memcpy(buffer_in0, buffer_in1, sizeof(uint8_t) * 512 / 8);
            memcpy(buffer_in1, buffer_in2, sizeof(uint8_t) * 512 / 8);
            memcpy(buffer_in2, buffer_out, sizeof(uint8_t) * 512 / 8);
        }

        // Validation
        test_passed += eval_cavp(&cavp, buffer_out, 512 / 8, t, SHA_MONTECARLO, SHA512_MONTECARLO_VERBOSE);

        memcpy(cavp.s, buffer_out, sizeof(uint8_t) * 512 / 8);
        if (t >= 3) break;
    }

    free_cavp(&cavp, SHA_MONTECARLO);
    free(buffer_in0);
    free(buffer_in1);
    free(buffer_in2);
    free(buffer_in3);
    free(buffer_out);

    return cavp.tot_tests - test_passed;
}

/*****************************************************************************/

int sha224_shortmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 224 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA224ShortMsg.rsp", SHA_SHORTMSG);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA224ShortMsg.rsp", SHA_SHORTMSG);
#endif // C_SIMULATION

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VOFF, "Run test # %u", t);

        const unsigned sha2_in_bytes = cavp.l[t] / 8;
        const unsigned sha2_out_bytes = 224 / 8;
        const unsigned sha2_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha2_batch;
        conf_info_data.in_bytes = sha2_in_bytes;
        conf_info_data.out_bytes = sha2_out_bytes;

        // Communication channels
        ac_channel<dma_info_t> dma_read_ctrl;
        ac_channel<dma_info_t> dma_write_ctrl;
        ac_channel<dma_data_t> dma_read_chnl;
        ac_channel<dma_data_t> dma_write_chnl;

        // Accelerator done (workaround)
        ac_sync acc_done;

        // Testbench data
        data_t inputs[PLM_IN_SIZE * BATCH_MAX];
        data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
        data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

        ESP_REPORT_INFO(VOFF, "Configuration:");
        ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
        ESP_REPORT_INFO(VOFF, "Other info:");
        ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha2_batch; b++) {
            for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha2_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha2_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha2_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha2_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha2_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha2_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha2_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha2_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha2_in_bytes + i+0] = d0;
                inputs[b * sha2_in_bytes + i+1] = d1;
                inputs[b * sha2_in_bytes + i+2] = d2;
                inputs[b * sha2_in_bytes + i+3] = d3;
                inputs[b * sha2_in_bytes + i+4] = d4;
                inputs[b * sha2_in_bytes + i+5] = d5;
                inputs[b * sha2_in_bytes + i+6] = d6;
                inputs[b * sha2_in_bytes + i+7] = d7;

                dma_data_t dma_data;
                dma_data.template set_slc<DATA_WIDTH>(0, d0);
                dma_data.template set_slc<DATA_WIDTH>(8, d1);
                dma_data.template set_slc<DATA_WIDTH>(16, d2);
                dma_data.template set_slc<DATA_WIDTH>(24, d3);
                dma_data.template set_slc<DATA_WIDTH>(32, d4);
                dma_data.template set_slc<DATA_WIDTH>(40, d5);
                dma_data.template set_slc<DATA_WIDTH>(48, d6);
                dma_data.template set_slc<DATA_WIDTH>(56, d7);

                dma_read_chnl.write(dma_data);
            }
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
        sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < sha2_out_bytes; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha2_out_bytes + i+0] = d0;
                outputs[b * sha2_out_bytes + i+1] = d1;
                outputs[b * sha2_out_bytes + i+2] = d2;
                outputs[b * sha2_out_bytes + i+3] = d3;
                outputs[b * sha2_out_bytes + i+4] = d4;
                outputs[b * sha2_out_bytes + i+5] = d5;
                outputs[b * sha2_out_bytes + i+6] = d6;
                outputs[b * sha2_out_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < sha2_out_bytes; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 224 / 8, t, SHA_SHORTMSG, SHA224_SHORTMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA224ShortMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_SHORTMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

int sha256_shortmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 256 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA256ShortMsg.rsp", SHA_SHORTMSG);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA256ShortMsg.rsp", SHA_SHORTMSG);
#endif // C_SIMULATION

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VOFF, "Run test # %u", t);

        const unsigned sha2_in_bytes = cavp.l[t] / 8;
        const unsigned sha2_out_bytes = 256 / 8;
        const unsigned sha2_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha2_batch;
        conf_info_data.in_bytes = sha2_in_bytes;
        conf_info_data.out_bytes = sha2_out_bytes;

        // Communication channels
        ac_channel<dma_info_t> dma_read_ctrl;
        ac_channel<dma_info_t> dma_write_ctrl;
        ac_channel<dma_data_t> dma_read_chnl;
        ac_channel<dma_data_t> dma_write_chnl;

        // Accelerator done (workaround)
        ac_sync acc_done;

        // Testbench data
        data_t inputs[PLM_IN_SIZE * BATCH_MAX];
        data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
        data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

        ESP_REPORT_INFO(VOFF, "Configuration:");
        ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
        ESP_REPORT_INFO(VOFF, "Other info:");
        ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha2_batch; b++) {
            for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha2_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha2_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha2_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha2_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha2_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha2_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha2_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha2_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha2_in_bytes + i+0] = d0;
                inputs[b * sha2_in_bytes + i+1] = d1;
                inputs[b * sha2_in_bytes + i+2] = d2;
                inputs[b * sha2_in_bytes + i+3] = d3;
                inputs[b * sha2_in_bytes + i+4] = d4;
                inputs[b * sha2_in_bytes + i+5] = d5;
                inputs[b * sha2_in_bytes + i+6] = d6;
                inputs[b * sha2_in_bytes + i+7] = d7;

                dma_data_t dma_data;
                dma_data.template set_slc<DATA_WIDTH>(0, d0);
                dma_data.template set_slc<DATA_WIDTH>(8, d1);
                dma_data.template set_slc<DATA_WIDTH>(16, d2);
                dma_data.template set_slc<DATA_WIDTH>(24, d3);
                dma_data.template set_slc<DATA_WIDTH>(32, d4);
                dma_data.template set_slc<DATA_WIDTH>(40, d5);
                dma_data.template set_slc<DATA_WIDTH>(48, d6);
                dma_data.template set_slc<DATA_WIDTH>(56, d7);

                dma_read_chnl.write(dma_data);
            }
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
        sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < sha2_out_bytes; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha2_out_bytes + i+0] = d0;
                outputs[b * sha2_out_bytes + i+1] = d1;
                outputs[b * sha2_out_bytes + i+2] = d2;
                outputs[b * sha2_out_bytes + i+3] = d3;
                outputs[b * sha2_out_bytes + i+4] = d4;
                outputs[b * sha2_out_bytes + i+5] = d5;
                outputs[b * sha2_out_bytes + i+6] = d6;
                outputs[b * sha2_out_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < sha2_out_bytes; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 256 / 8, t, SHA_SHORTMSG, SHA256_SHORTMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA256ShortMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_SHORTMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

int sha384_shortmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 384 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA384ShortMsg.rsp", SHA_SHORTMSG);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA384ShortMsg.rsp", SHA_SHORTMSG);
#endif // C_SIMULATION

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VOFF, "Run test # %u", t);

        const unsigned sha2_in_bytes = cavp.l[t] / 8;
        const unsigned sha2_out_bytes = 384 / 8;
        const unsigned sha2_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha2_batch;
        conf_info_data.in_bytes = sha2_in_bytes;
        conf_info_data.out_bytes = sha2_out_bytes;

        // Communication channels
        ac_channel<dma_info_t> dma_read_ctrl;
        ac_channel<dma_info_t> dma_write_ctrl;
        ac_channel<dma_data_t> dma_read_chnl;
        ac_channel<dma_data_t> dma_write_chnl;

        // Accelerator done (workaround)
        ac_sync acc_done;

        // Testbench data
        data_t inputs[PLM_IN_SIZE * BATCH_MAX];
        data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
        data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

        ESP_REPORT_INFO(VOFF, "Configuration:");
        ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
        ESP_REPORT_INFO(VOFF, "Other info:");
        ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha2_batch; b++) {
            for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha2_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha2_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha2_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha2_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha2_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha2_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha2_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha2_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha2_in_bytes + i+0] = d0;
                inputs[b * sha2_in_bytes + i+1] = d1;
                inputs[b * sha2_in_bytes + i+2] = d2;
                inputs[b * sha2_in_bytes + i+3] = d3;
                inputs[b * sha2_in_bytes + i+4] = d4;
                inputs[b * sha2_in_bytes + i+5] = d5;
                inputs[b * sha2_in_bytes + i+6] = d6;
                inputs[b * sha2_in_bytes + i+7] = d7;

                dma_data_t dma_data;
                dma_data.template set_slc<DATA_WIDTH>(0, d0);
                dma_data.template set_slc<DATA_WIDTH>(8, d1);
                dma_data.template set_slc<DATA_WIDTH>(16, d2);
                dma_data.template set_slc<DATA_WIDTH>(24, d3);
                dma_data.template set_slc<DATA_WIDTH>(32, d4);
                dma_data.template set_slc<DATA_WIDTH>(40, d5);
                dma_data.template set_slc<DATA_WIDTH>(48, d6);
                dma_data.template set_slc<DATA_WIDTH>(56, d7);

                dma_read_chnl.write(dma_data);
            }
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
        sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < sha2_out_bytes; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha2_out_bytes + i+0] = d0;
                outputs[b * sha2_out_bytes + i+1] = d1;
                outputs[b * sha2_out_bytes + i+2] = d2;
                outputs[b * sha2_out_bytes + i+3] = d3;
                outputs[b * sha2_out_bytes + i+4] = d4;
                outputs[b * sha2_out_bytes + i+5] = d5;
                outputs[b * sha2_out_bytes + i+6] = d6;
                outputs[b * sha2_out_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < sha2_out_bytes; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 384 / 8, t, SHA_SHORTMSG, SHA384_SHORTMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA384ShortMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_SHORTMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

int sha512_shortmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 512 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA512ShortMsg.rsp", SHA_SHORTMSG);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA512ShortMsg.rsp", SHA_SHORTMSG);
#endif // C_SIMULATION

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VOFF, "Run test # %u", t);

        const unsigned sha2_in_bytes = cavp.l[t] / 8;
        const unsigned sha2_out_bytes = 512 / 8;
        const unsigned sha2_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha2_batch;
        conf_info_data.in_bytes = sha2_in_bytes;
        conf_info_data.out_bytes = sha2_out_bytes;

        // Communication channels
        ac_channel<dma_info_t> dma_read_ctrl;
        ac_channel<dma_info_t> dma_write_ctrl;
        ac_channel<dma_data_t> dma_read_chnl;
        ac_channel<dma_data_t> dma_write_chnl;

        // Accelerator done (workaround)
        ac_sync acc_done;

        // Testbench data
        data_t inputs[PLM_IN_SIZE * BATCH_MAX];
        data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
        data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

        ESP_REPORT_INFO(VOFF, "Configuration:");
        ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
        ESP_REPORT_INFO(VOFF, "Other info:");
        ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha2_batch; b++) {
            for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha2_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha2_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha2_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha2_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha2_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha2_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha2_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha2_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha2_in_bytes + i+0] = d0;
                inputs[b * sha2_in_bytes + i+1] = d1;
                inputs[b * sha2_in_bytes + i+2] = d2;
                inputs[b * sha2_in_bytes + i+3] = d3;
                inputs[b * sha2_in_bytes + i+4] = d4;
                inputs[b * sha2_in_bytes + i+5] = d5;
                inputs[b * sha2_in_bytes + i+6] = d6;
                inputs[b * sha2_in_bytes + i+7] = d7;

                dma_data_t dma_data;
                dma_data.template set_slc<DATA_WIDTH>(0, d0);
                dma_data.template set_slc<DATA_WIDTH>(8, d1);
                dma_data.template set_slc<DATA_WIDTH>(16, d2);
                dma_data.template set_slc<DATA_WIDTH>(24, d3);
                dma_data.template set_slc<DATA_WIDTH>(32, d4);
                dma_data.template set_slc<DATA_WIDTH>(40, d5);
                dma_data.template set_slc<DATA_WIDTH>(48, d6);
                dma_data.template set_slc<DATA_WIDTH>(56, d7);

                dma_read_chnl.write(dma_data);
            }
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
        sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < sha2_out_bytes; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha2_out_bytes + i+0] = d0;
                outputs[b * sha2_out_bytes + i+1] = d1;
                outputs[b * sha2_out_bytes + i+2] = d2;
                outputs[b * sha2_out_bytes + i+3] = d3;
                outputs[b * sha2_out_bytes + i+4] = d4;
                outputs[b * sha2_out_bytes + i+5] = d5;
                outputs[b * sha2_out_bytes + i+6] = d6;
                outputs[b * sha2_out_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < sha2_out_bytes; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 512 / 8, t, SHA_SHORTMSG, SHA512_SHORTMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA512ShortMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_SHORTMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

/*****************************************************************************/

int sha224_longmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 224 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA224LongMsg.rsp", SHA_LONGMSG);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA224LongMsg.rsp", SHA_LONGMSG);
#endif // C_SIMULATION

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VOFF, "Run test # %u", t);

        const unsigned sha2_in_bytes = cavp.l[t] / 8;
        const unsigned sha2_out_bytes = 224 / 8;
        const unsigned sha2_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha2_batch;
        conf_info_data.in_bytes = sha2_in_bytes;
        conf_info_data.out_bytes = sha2_out_bytes;

        // Communication channels
        ac_channel<dma_info_t> dma_read_ctrl;
        ac_channel<dma_info_t> dma_write_ctrl;
        ac_channel<dma_data_t> dma_read_chnl;
        ac_channel<dma_data_t> dma_write_chnl;

        // Accelerator done (workaround)
        ac_sync acc_done;

        // Testbench data
        data_t inputs[PLM_IN_SIZE * BATCH_MAX];
        data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
        data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

        ESP_REPORT_INFO(VOFF, "Configuration:");
        ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
        ESP_REPORT_INFO(VOFF, "Other info:");
        ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha2_batch; b++) {
            for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha2_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha2_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha2_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha2_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha2_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha2_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha2_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha2_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha2_in_bytes + i+0] = d0;
                inputs[b * sha2_in_bytes + i+1] = d1;
                inputs[b * sha2_in_bytes + i+2] = d2;
                inputs[b * sha2_in_bytes + i+3] = d3;
                inputs[b * sha2_in_bytes + i+4] = d4;
                inputs[b * sha2_in_bytes + i+5] = d5;
                inputs[b * sha2_in_bytes + i+6] = d6;
                inputs[b * sha2_in_bytes + i+7] = d7;

                dma_data_t dma_data;
                dma_data.template set_slc<DATA_WIDTH>(0, d0);
                dma_data.template set_slc<DATA_WIDTH>(8, d1);
                dma_data.template set_slc<DATA_WIDTH>(16, d2);
                dma_data.template set_slc<DATA_WIDTH>(24, d3);
                dma_data.template set_slc<DATA_WIDTH>(32, d4);
                dma_data.template set_slc<DATA_WIDTH>(40, d5);
                dma_data.template set_slc<DATA_WIDTH>(48, d6);
                dma_data.template set_slc<DATA_WIDTH>(56, d7);

                dma_read_chnl.write(dma_data);
            }
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
        sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < sha2_out_bytes; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha2_out_bytes + i+0] = d0;
                outputs[b * sha2_out_bytes + i+1] = d1;
                outputs[b * sha2_out_bytes + i+2] = d2;
                outputs[b * sha2_out_bytes + i+3] = d3;
                outputs[b * sha2_out_bytes + i+4] = d4;
                outputs[b * sha2_out_bytes + i+5] = d5;
                outputs[b * sha2_out_bytes + i+6] = d6;
                outputs[b * sha2_out_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < sha2_out_bytes; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 224 / 8, t, SHA_LONGMSG, SHA224_LONGMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA224LongMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_LONGMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

int sha256_longmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 256 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA256LongMsg.rsp", SHA_LONGMSG);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA256LongMsg.rsp", SHA_LONGMSG);
#endif // C_SIMULATION

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VOFF, "Run test # %u", t);

        const unsigned sha2_in_bytes = cavp.l[t] / 8;
        const unsigned sha2_out_bytes = 256 / 8;
        const unsigned sha2_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha2_batch;
        conf_info_data.in_bytes = sha2_in_bytes;
        conf_info_data.out_bytes = sha2_out_bytes;

        // Communication channels
        ac_channel<dma_info_t> dma_read_ctrl;
        ac_channel<dma_info_t> dma_write_ctrl;
        ac_channel<dma_data_t> dma_read_chnl;
        ac_channel<dma_data_t> dma_write_chnl;

        // Accelerator done (workaround)
        ac_sync acc_done;

        // Testbench data
        data_t inputs[PLM_IN_SIZE * BATCH_MAX];
        data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
        data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

        ESP_REPORT_INFO(VOFF, "Configuration:");
        ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
        ESP_REPORT_INFO(VOFF, "Other info:");
        ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha2_batch; b++) {
            for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha2_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha2_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha2_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha2_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha2_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha2_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha2_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha2_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha2_in_bytes + i+0] = d0;
                inputs[b * sha2_in_bytes + i+1] = d1;
                inputs[b * sha2_in_bytes + i+2] = d2;
                inputs[b * sha2_in_bytes + i+3] = d3;
                inputs[b * sha2_in_bytes + i+4] = d4;
                inputs[b * sha2_in_bytes + i+5] = d5;
                inputs[b * sha2_in_bytes + i+6] = d6;
                inputs[b * sha2_in_bytes + i+7] = d7;

                dma_data_t dma_data;
                dma_data.template set_slc<DATA_WIDTH>(0, d0);
                dma_data.template set_slc<DATA_WIDTH>(8, d1);
                dma_data.template set_slc<DATA_WIDTH>(16, d2);
                dma_data.template set_slc<DATA_WIDTH>(24, d3);
                dma_data.template set_slc<DATA_WIDTH>(32, d4);
                dma_data.template set_slc<DATA_WIDTH>(40, d5);
                dma_data.template set_slc<DATA_WIDTH>(48, d6);
                dma_data.template set_slc<DATA_WIDTH>(56, d7);

                dma_read_chnl.write(dma_data);
            }
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
        sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < sha2_out_bytes; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha2_out_bytes + i+0] = d0;
                outputs[b * sha2_out_bytes + i+1] = d1;
                outputs[b * sha2_out_bytes + i+2] = d2;
                outputs[b * sha2_out_bytes + i+3] = d3;
                outputs[b * sha2_out_bytes + i+4] = d4;
                outputs[b * sha2_out_bytes + i+5] = d5;
                outputs[b * sha2_out_bytes + i+6] = d6;
                outputs[b * sha2_out_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < sha2_out_bytes; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 256 / 8, t, SHA_LONGMSG, SHA256_LONGMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA256LongMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_LONGMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

int sha384_longmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 384 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA384LongMsg.rsp", SHA_LONGMSG);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA384LongMsg.rsp", SHA_LONGMSG);
#endif // C_SIMULATION

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VOFF, "Run test # %u", t);

        const unsigned sha2_in_bytes = cavp.l[t] / 8;
        const unsigned sha2_out_bytes = 384 / 8;
        const unsigned sha2_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha2_batch;
        conf_info_data.in_bytes = sha2_in_bytes;
        conf_info_data.out_bytes = sha2_out_bytes;

        // Communication channels
        ac_channel<dma_info_t> dma_read_ctrl;
        ac_channel<dma_info_t> dma_write_ctrl;
        ac_channel<dma_data_t> dma_read_chnl;
        ac_channel<dma_data_t> dma_write_chnl;

        // Accelerator done (workaround)
        ac_sync acc_done;

        // Testbench data
        data_t inputs[PLM_IN_SIZE * BATCH_MAX];
        data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
        data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

        ESP_REPORT_INFO(VOFF, "Configuration:");
        ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
        ESP_REPORT_INFO(VOFF, "Other info:");
        ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha2_batch; b++) {
            for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha2_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha2_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha2_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha2_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha2_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha2_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha2_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha2_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha2_in_bytes + i+0] = d0;
                inputs[b * sha2_in_bytes + i+1] = d1;
                inputs[b * sha2_in_bytes + i+2] = d2;
                inputs[b * sha2_in_bytes + i+3] = d3;
                inputs[b * sha2_in_bytes + i+4] = d4;
                inputs[b * sha2_in_bytes + i+5] = d5;
                inputs[b * sha2_in_bytes + i+6] = d6;
                inputs[b * sha2_in_bytes + i+7] = d7;

                dma_data_t dma_data;
                dma_data.template set_slc<DATA_WIDTH>(0, d0);
                dma_data.template set_slc<DATA_WIDTH>(8, d1);
                dma_data.template set_slc<DATA_WIDTH>(16, d2);
                dma_data.template set_slc<DATA_WIDTH>(24, d3);
                dma_data.template set_slc<DATA_WIDTH>(32, d4);
                dma_data.template set_slc<DATA_WIDTH>(40, d5);
                dma_data.template set_slc<DATA_WIDTH>(48, d6);
                dma_data.template set_slc<DATA_WIDTH>(56, d7);

                dma_read_chnl.write(dma_data);
            }
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
        sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < sha2_out_bytes; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha2_out_bytes + i+0] = d0;
                outputs[b * sha2_out_bytes + i+1] = d1;
                outputs[b * sha2_out_bytes + i+2] = d2;
                outputs[b * sha2_out_bytes + i+3] = d3;
                outputs[b * sha2_out_bytes + i+4] = d4;
                outputs[b * sha2_out_bytes + i+5] = d5;
                outputs[b * sha2_out_bytes + i+6] = d6;
                outputs[b * sha2_out_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < sha2_out_bytes; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 384 / 8, t, SHA_LONGMSG, SHA384_LONGMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA384LongMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_LONGMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

int sha512_longmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 512 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha2byte/SHA512LongMsg.rsp", SHA_LONGMSG);
#else
    parse_cavp(&cavp, "../tests/sha2byte/SHA512LongMsg.rsp", SHA_LONGMSG);
#endif // C_SIMULATION

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VOFF, "Run test # %u", t);

        const unsigned sha2_in_bytes = cavp.l[t] / 8;
        const unsigned sha2_out_bytes = 512 / 8;
        const unsigned sha2_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha2_batch;
        conf_info_data.in_bytes = sha2_in_bytes;
        conf_info_data.out_bytes = sha2_out_bytes;

        // Communication channels
        ac_channel<dma_info_t> dma_read_ctrl;
        ac_channel<dma_info_t> dma_write_ctrl;
        ac_channel<dma_data_t> dma_read_chnl;
        ac_channel<dma_data_t> dma_write_chnl;

        // Accelerator done (workaround)
        ac_sync acc_done;

        // Testbench data
        data_t inputs[PLM_IN_SIZE * BATCH_MAX];
        data_t outputs[PLM_OUT_SIZE * BATCH_MAX];
        data_t gold_outputs[PLM_OUT_SIZE * BATCH_MAX];

        ESP_REPORT_INFO(VOFF, "Configuration:");
        ESP_REPORT_INFO(VOFF, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VOFF, "  - out_bytes: %u", ESP_TO_UINT32(conf_info_data.out_bytes));
        ESP_REPORT_INFO(VOFF, "Other info:");
        ESP_REPORT_INFO(VOFF, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VOFF, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VOFF, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VOFF, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VOFF, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha2_batch; b++) {
            for (unsigned i = 0; i < sha2_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha2_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha2_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha2_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha2_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha2_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha2_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha2_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha2_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha2_in_bytes + i+0] = d0;
                inputs[b * sha2_in_bytes + i+1] = d1;
                inputs[b * sha2_in_bytes + i+2] = d2;
                inputs[b * sha2_in_bytes + i+3] = d3;
                inputs[b * sha2_in_bytes + i+4] = d4;
                inputs[b * sha2_in_bytes + i+5] = d5;
                inputs[b * sha2_in_bytes + i+6] = d6;
                inputs[b * sha2_in_bytes + i+7] = d7;

                dma_data_t dma_data;
                dma_data.template set_slc<DATA_WIDTH>(0, d0);
                dma_data.template set_slc<DATA_WIDTH>(8, d1);
                dma_data.template set_slc<DATA_WIDTH>(16, d2);
                dma_data.template set_slc<DATA_WIDTH>(24, d3);
                dma_data.template set_slc<DATA_WIDTH>(32, d4);
                dma_data.template set_slc<DATA_WIDTH>(40, d5);
                dma_data.template set_slc<DATA_WIDTH>(48, d6);
                dma_data.template set_slc<DATA_WIDTH>(56, d7);

                dma_read_chnl.write(dma_data);
            }
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
        sha2_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * conf_info_data.out_bytes).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < sha2_out_bytes; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < sha2_out_bytes) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha2_out_bytes + i+0] = d0;
                outputs[b * sha2_out_bytes + i+1] = d1;
                outputs[b * sha2_out_bytes + i+2] = d2;
                outputs[b * sha2_out_bytes + i+3] = d3;
                outputs[b * sha2_out_bytes + i+4] = d4;
                outputs[b * sha2_out_bytes + i+5] = d5;
                outputs[b * sha2_out_bytes + i+6] = d6;
                outputs[b * sha2_out_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < sha2_out_bytes; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 512 / 8, t, SHA_LONGMSG, SHA512_LONGMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA512LongMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_LONGMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

#endif /* __TESTS_H__ */
