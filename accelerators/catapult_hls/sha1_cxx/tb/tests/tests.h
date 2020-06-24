#ifndef __TESTS_H__
#define __TESTS_H__

#include "sha1.h"
#include "utils.h"

#include <cmath>

/* SHA1BYTE Monte Carlo Test Vectors */

#define SHA1_MONTECARLO_VERBOSE 0

/* SHA1BYTE Short Message (ShortMsg) Test Vectors */

#define SHA1_SHORTMSG_VERBOSE 0

/* SHA1BYTE Long Message (LongMsg) Test Vectors */

#define SHA1_LONGMSG_VERBOSE 0

/*****************************************************************************/

int sha1_montecarlo(void)
{
    unsigned i, j, k;
    uint8_t *buffer_in0;
    uint8_t *buffer_in1;
    uint8_t *buffer_in2;
    uint8_t *buffer_in3;
    uint8_t *buffer_out;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer_in0 = (uint8_t *) malloc(sizeof(uint8_t) * 160 / 8);
    buffer_in1 = (uint8_t *) malloc(sizeof(uint8_t) * 160 / 8);
    buffer_in2 = (uint8_t *) malloc(sizeof(uint8_t) * 160 / 8);
    buffer_in3 = (uint8_t *) malloc(3 * sizeof(uint8_t) * 160 / 8);
    buffer_out = (uint8_t *) malloc(sizeof(uint8_t) * 160 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha1byte/SHA1Monte.rsp", SHA_MONTECARLO);
#else
    parse_cavp(&cavp, "../tests/sha1byte/SHA1Monte.rsp", SHA_MONTECARLO);
#endif

    ESP_REPORT_INFO(VON, "Total tests: %u", cavp.tot_tests);

//    for (i = 0; i < cavp.tot_tests; ++i)
//    {
//        memcpy(buffer_in0, cavp.s, sizeof(uint8_t) * 160 / 8);
//        memcpy(buffer_in1, cavp.s, sizeof(uint8_t) * 160 / 8);
//        memcpy(buffer_in2, cavp.s, sizeof(uint8_t) * 160 / 8);
//
//        for (j = 3; j < 1003; ++j)
//        {
//            for (k = 0; k < 160 / 8; ++k)
//            {
//                // Concatenate buffer_in0, in1 and in2
//                buffer_in3[k + 0      ] = buffer_in0[k];
//                buffer_in3[k + 160 / 8] = buffer_in1[k];
//                buffer_in3[k + 160 / 4] = buffer_in2[k];
//            }
//
//            sha1(3 * 160 / 8, buffer_in3, buffer_out);
//
//            memcpy(buffer_in0, buffer_in1, sizeof(uint8_t) * 160 / 8);
//            memcpy(buffer_in1, buffer_in2, sizeof(uint8_t) * 160 / 8);
//            memcpy(buffer_in2, buffer_out, sizeof(uint8_t) * 160 / 8);
//        }
//
//        test_passed += eval_cavp(&cavp, buffer_out, 160 / 8, i,
//              SHA_MONTECARLO, SHA1_MONTECARLO_VERBOSE);
//
//        memcpy(cavp.s, buffer_out, sizeof(uint8_t) * 160 / 8);
//    }
//
//    printf("Info: test passed #%u out of #%u (SHA1MonteCarlo)\n",
//           test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_MONTECARLO);
    free(buffer_in0);
    free(buffer_in1);
    free(buffer_in2);
    free(buffer_in3);
    free(buffer_out);

    return cavp.tot_tests - test_passed;
}

/*****************************************************************************/

int sha1_shortmsg(void)
{
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 160 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha1byte/SHA1ShortMsg.rsp", SHA_SHORTMSG);
#else
    parse_cavp(&cavp, "../tests/sha1byte/SHA1ShortMsg.rsp", SHA_SHORTMSG);
#endif

    ESP_REPORT_INFO(VON, "Total tests: %u", cavp.tot_tests);

    ESP_REPORT_INFO(VON, "---------------------------------------");

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VON, "Run test # %u", t);

        const unsigned sha1_in_bytes = cavp.l[t] / 8;
        const unsigned sha1_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha1_batch;
        conf_info_data.in_bytes = sha1_in_bytes;

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

        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VON, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VON, "Other info:");
        ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VON, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VON, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VON, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VON, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VON, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VON, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VON, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha1_batch; b++) {
           for (unsigned i = 0; i < sha1_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha1_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha1_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha1_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha1_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha1_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha1_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha1_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha1_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha1_in_bytes + i+0] = d0;
                inputs[b * sha1_in_bytes + i+1] = d1;
                inputs[b * sha1_in_bytes + i+2] = d2;
                inputs[b * sha1_in_bytes + i+3] = d3;
                inputs[b * sha1_in_bytes + i+4] = d4;
                inputs[b * sha1_in_bytes + i+5] = d5;
                inputs[b * sha1_in_bytes + i+6] = d6;
                inputs[b * sha1_in_bytes + i+7] = d7;

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
        sha1_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * SHA1_DIGEST_LENGTH).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < SHA1_DIGEST_LENGTH; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha1_in_bytes + i+0] = d0;
                outputs[b * sha1_in_bytes + i+1] = d1;
                outputs[b * sha1_in_bytes + i+2] = d2;
                outputs[b * sha1_in_bytes + i+3] = d3;
                outputs[b * sha1_in_bytes + i+4] = d4;
                outputs[b * sha1_in_bytes + i+5] = d5;
                outputs[b * sha1_in_bytes + i+6] = d6;
                outputs[b * sha1_in_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < SHA1_DIGEST_LENGTH; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 160 / 8, t, SHA_SHORTMSG, SHA1_SHORTMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA1ShortMsg)", test_passed, cavp.tot_tests);

    free_cavp(&cavp, SHA_SHORTMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

/*****************************************************************************/

int sha1_longmsg(void)
{
    unsigned i;
    uint8_t *buffer;
    unsigned test_passed = 0;

    cavp_data cavp;

    buffer = (uint8_t *) malloc(sizeof(uint8_t) * 160 / 8);

#ifdef C_SIMULATION
    parse_cavp(&cavp, "../tests/sha1byte/SHA1LongMsg.rsp", SHA_LONGMSG);
#else
    parse_cavp(&cavp, "../tests/sha1byte/SHA1LongMsg.rsp", SHA_LONGMSG);
#endif

    ESP_REPORT_INFO(VON, "Total tests: %u", cavp.tot_tests);

    ESP_REPORT_INFO(VON, "---------------------------------------");

    for (unsigned t = 0; t < cavp.tot_tests; ++t)
    {
        ESP_REPORT_INFO(VON, "Run test # %u", t);

        const unsigned sha1_in_bytes = cavp.l[t] / 8;
        const unsigned sha1_batch = 1;

        // Accelerator configuration
        ac_channel<conf_info_t> conf_info;

        conf_info_t conf_info_data;
        conf_info_data.batch = sha1_batch;
        conf_info_data.in_bytes = sha1_in_bytes;

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

        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VON, "  - in_bytes: %u", ESP_TO_UINT32(conf_info_data.in_bytes));
        ESP_REPORT_INFO(VON, "Other info:");
        ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
        ESP_REPORT_INFO(VON, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
        ESP_REPORT_INFO(VON, "  - PLM-IN size: %u", PLM_IN_SIZE);
        ESP_REPORT_INFO(VON, "  - PLM-OUT size: %u", PLM_OUT_SIZE);
        ESP_REPORT_INFO(VON, "  - DATA width: %u", DATA_WIDTH);
        ESP_REPORT_INFO(VON, "  - memory in (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VON, "  - memory out (words): %u", ESP_TO_UINT32(conf_info_data.in_bytes) * ESP_TO_UINT32(conf_info_data.batch));
        ESP_REPORT_INFO(VON, "---------------------------------------");

        // Pass inputs to the accelerator
        for (unsigned b = 0; b < sha1_batch; b++) {
           for (unsigned i = 0; i < sha1_in_bytes; i+=8) {

                data_t d0 = (i+0 < sha1_in_bytes) ? cavp.m[t][i+0] : data_t(0);
                data_t d1 = (i+1 < sha1_in_bytes) ? cavp.m[t][i+1] : data_t(0);
                data_t d2 = (i+2 < sha1_in_bytes) ? cavp.m[t][i+2] : data_t(0);
                data_t d3 = (i+3 < sha1_in_bytes) ? cavp.m[t][i+3] : data_t(0);
                data_t d4 = (i+4 < sha1_in_bytes) ? cavp.m[t][i+4] : data_t(0);
                data_t d5 = (i+5 < sha1_in_bytes) ? cavp.m[t][i+5] : data_t(0);
                data_t d6 = (i+6 < sha1_in_bytes) ? cavp.m[t][i+6] : data_t(0);
                data_t d7 = (i+7 < sha1_in_bytes) ? cavp.m[t][i+7] : data_t(0);

                inputs[b * sha1_in_bytes + i+0] = d0;
                inputs[b * sha1_in_bytes + i+1] = d1;
                inputs[b * sha1_in_bytes + i+2] = d2;
                inputs[b * sha1_in_bytes + i+3] = d3;
                inputs[b * sha1_in_bytes + i+4] = d4;
                inputs[b * sha1_in_bytes + i+5] = d5;
                inputs[b * sha1_in_bytes + i+6] = d6;
                inputs[b * sha1_in_bytes + i+7] = d7;

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
        sha1_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

        unsigned dma_word_count = ceil((conf_info_data.batch * SHA1_DIGEST_LENGTH).to_uint() / (float)8);
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(dma_word_count)) {} // Testbench stalls until data ready
        for (unsigned b = 0; b < conf_info_data.batch; b++) {
            for (unsigned i = 0; i < SHA1_DIGEST_LENGTH; i+=8) {

                dma_data_t dma_data = dma_write_chnl.read();

                data_t d0 = (i+0 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(0) : data_t(0);
                data_t d1 = (i+1 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(8) : data_t(0);
                data_t d2 = (i+2 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(16) : data_t(0);
                data_t d3 = (i+3 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(24) : data_t(0);
                data_t d4 = (i+4 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(32) : data_t(0);
                data_t d5 = (i+5 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(40) : data_t(0);
                data_t d6 = (i+6 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(48) : data_t(0);
                data_t d7 = (i+7 < SHA1_DIGEST_LENGTH) ? dma_data.template slc<DATA_WIDTH>(56) : data_t(0);

                outputs[b * sha1_in_bytes + i+0] = d0;
                outputs[b * sha1_in_bytes + i+1] = d1;
                outputs[b * sha1_in_bytes + i+2] = d2;
                outputs[b * sha1_in_bytes + i+3] = d3;
                outputs[b * sha1_in_bytes + i+4] = d4;
                outputs[b * sha1_in_bytes + i+5] = d5;
                outputs[b * sha1_in_bytes + i+6] = d6;
                outputs[b * sha1_in_bytes + i+7] = d7;
            }
        }

        // Validation
        for (unsigned i = 0; i < SHA1_DIGEST_LENGTH; i++) {
            buffer[i] = outputs[i];
        }
        test_passed += eval_cavp(&cavp, buffer, 160 / 8, t, SHA_LONGMSG, SHA1_LONGMSG_VERBOSE);
    }

    ESP_REPORT_INFO(VON, "Test passed #%u out of #%u (SHA1LongMsg)", test_passed, cavp.tot_tests);

//    for (i = 0; i < cavp.tot_tests; ++i)
//    {
//        sha1(cavp.l[i] / 8, cavp.m[i], buffer);
//
//        test_passed += eval_cavp(&cavp, buffer, 160 / 8, i,
//                SHA_LONGMSG, SHA1_LONGMSG_VERBOSE);
//    }
//
//    printf("Info: test passed #%u out of #%u (SHA1LongMsg)\n",
//           test_passed, cavp.tot_tests);
//
    free_cavp(&cavp, SHA_LONGMSG);
    free(buffer);

    return cavp.tot_tests - test_passed;
}

/*****************************************************************************/

#endif /* __TESTS_H__ */
