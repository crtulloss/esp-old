#include "add_accelerator.h"

#include <cstdlib>
#include <cstdio>

#include <mc_scverify.h>   // Enable SCVerify

void add_accelerator_tb(unsigned length, DATA_WORD *input1, DATA_WORD *input2, unsigned long *output, unsigned &ret) {
	for (unsigned i = 0; i < length; ++i)
    {
        output[i] = input1[i].to_uint64() + input2[i].to_uint64();
    }

    ret = 0;
}

CCS_MAIN(int argv, char **argc) {
    ESP_REPORT_INFO(VON, "---------------------------------------");
    ESP_REPORT_INFO(VON, "ESP - AddAccelerator [Catapult HLS C++]");
    ESP_REPORT_INFO(VON, "      Single block");
    ESP_REPORT_INFO(VON, "---------------------------------------");

    const unsigned add_accelerator_length = PLM_SIZE;
    const unsigned add_accelerator_batch = 16;

    // Testbench return value (0 = PASS, non-0 = FAIL)
    int rc = 0;

    // Accelerator configuration
    ac_channel<conf_info_t> conf_info;

    conf_info_t conf_info_data;
    conf_info_data.batch = add_accelerator_batch;
    conf_info_data.length = add_accelerator_length;

    // Communication channels
    ac_channel<dma_info_t> dma_read_ctrl;
    ac_channel<dma_info_t> dma_write_ctrl;
    ac_channel<dma_data_t> dma_read_chnl;
    ac_channel<dma_data_t> dma_write_chnl;

    // Accelerator done (workaround)
    ac_sync acc_done;

    // Testbench data
    DATA_WORD inputs1[PLM_SIZE * BATCH_MAX];
    DATA_WORD inputs2[PLM_SIZE * BATCH_MAX];
    DATA_WORD outputs[PLM_SIZE * BATCH_MAX];
    unsigned long gold_outputs[PLM_SIZE * BATCH_MAX];

    ESP_REPORT_INFO(VON, "Configuration:");
    ESP_REPORT_INFO(VON, "  - batch: %u", ESP_TO_UINT32(conf_info_data.batch));
    ESP_REPORT_INFO(VON, "  - length: %u", ESP_TO_UINT32(conf_info_data.length));
    ESP_REPORT_INFO(VON, "Other info:");
    ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
    ESP_REPORT_INFO(VON, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
    ESP_REPORT_INFO(VON, "  - PLM size: %u", PLM_SIZE);
    ESP_REPORT_INFO(VON, "  - DATA width: %u", DATA_WIDTH);
    ESP_REPORT_INFO(VON, "  - memory in (words): %u", add_accelerator_length * ESP_TO_UINT32(conf_info_data.batch));
    ESP_REPORT_INFO(VON, "  - memory out (words): %u", add_accelerator_length * ESP_TO_UINT32(conf_info_data.batch));
    ESP_REPORT_INFO(VON, "---------------------------------------");

    // Pass inputs to the accelerator
    for (unsigned b = 0; b < add_accelerator_batch; b++) {
        for (unsigned i = 0; i < add_accelerator_length; i++) {
            DATA_WORD data = (b * add_accelerator_length + i) % 1024;
            inputs1[b * add_accelerator_length + i] = data;
            dma_read_chnl.write(data);
        }

        for (unsigned i = 0; i < add_accelerator_length; i++) {
            DATA_WORD data = ((b * add_accelerator_length + i) + 1) % 1024;
            inputs2[b * add_accelerator_length + i] = data;
            dma_read_chnl.write(data);
        }
    }

    // Pass configuration to the accelerator
    conf_info.write(conf_info_data);

    // Run the accelerator
    add_accelerator_cxx(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);

    // Fetch outputs from the accelerator
    while (!dma_write_chnl.available(conf_info_data.batch * add_accelerator_length)) {} // Testbench stalls until data ready
    for (unsigned b = 0; b < conf_info_data.batch; b++) {
        for (unsigned i = 0; i < add_accelerator_length; i++) {
            DATA_WORD data = dma_write_chnl.read();
            outputs[b * add_accelerator_length + i] = data;
        }
    }

    // Validation
    ESP_REPORT_INFO(VON, "---------------------------------------");
    for (unsigned b = 0; b < conf_info_data.batch; b++) {
        unsigned ret = 0;
        add_accelerator_tb(add_accelerator_length, inputs1 + (b * add_accelerator_length), inputs2 + (b * add_accelerator_length), gold_outputs + (b * add_accelerator_length), ret);
    }
    unsigned errors = 0;

    for (unsigned b = 0; b < conf_info_data.batch; b++) {
        for (unsigned i = 0; i < add_accelerator_length; i++) {
            unsigned long gold = gold_outputs[b * add_accelerator_length + i];
            DATA_WORD data = outputs[b * add_accelerator_length + i];

            if (data != gold) {
                ESP_REPORT_INFO(VON, "[%u]: %llu (expected %lu)", b * add_accelerator_length + i, data.to_int64(), gold);
                errors++;
            }
        }
    }

    if (errors > 0) {
        ESP_REPORT_INFO(VON, "Validation: FAIL (errors %u / total %u)", errors, add_accelerator_batch * add_accelerator_length);
        rc = 1;
    } else {
        ESP_REPORT_INFO(VON, "Validation: PASS");
        rc = 0;
    }
    ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, add_accelerator_batch * add_accelerator_length);
    ESP_REPORT_INFO(VON, "---------------------------------------");

    CCS_RETURN(rc);
}
