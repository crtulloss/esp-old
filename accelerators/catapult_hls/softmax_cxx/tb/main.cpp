//#include "../inc/espacc_config.h"
//#include "../inc/espacc.h"

#include "softmax.hpp"
#include "esp_headers.hpp" // ESP-common headers

#include <cstdlib>
#include <cstdio>

#include <mc_scverify.h>   // Enable SCVerify

void softmax_tb(FPDATA_IN *input, double *output) {
    double exp_in[PLM_SIZE];
    double sum_exp = 0;
    for (unsigned i = 0; i < PLM_SIZE; i++) {
        exp_in[i] = exp(input[i].to_double());
        sum_exp += exp_in[i];
    }
    for (unsigned i = 0; i < PLM_SIZE; i++) { output[i] = exp_in[i]/sum_exp; }
}

double abs_double(const double &input)
{
    return input < 0 ? -input : input;
}

CCS_MAIN(int argv, char **argc) {
    ESP_REPORT_INFO(VON, "--------------------------------");
    ESP_REPORT_INFO(VON, "ESP - SoftMax [Catapult HLS C++]");
    ESP_REPORT_INFO(VON, "--------------------------------");

    // Testbench return value (0 = PASS, non-0 = FAIL)
    int rc = 0;

    // Debug information (return)
    debug_info_t debug;

    // Accelerator configuration
    conf_info_t conf_info;
    conf_info.batch = 1;
    
    const unsigned softmax_size = PLM_SIZE;

    ESP_REPORT_INFO(VON, "Configuration:");
    ESP_REPORT_INFO(VON, "  - batch: %u", ESP_TO_UINT32(conf_info.batch));
    ESP_REPORT_INFO(VON, "Other info:");
    ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
    ESP_REPORT_INFO(VON, "  - DMA size [2 = 32b, 3 = 64b]: %u", DMA_SIZE);
    ESP_REPORT_INFO(VON, "  - PLM size: %u", PLM_SIZE);
    ESP_REPORT_INFO(VON, "  - DATA width: %u", DATA_WIDTH);
    ESP_REPORT_INFO(VON, "  - SoftMax size: %u", softmax_size);
    ESP_REPORT_INFO(VON, "  - memory in (words): %u", softmax_size * ESP_TO_UINT32(conf_info.batch));
    ESP_REPORT_INFO(VON, "  - memory out (words): %u", softmax_size * ESP_TO_UINT32(conf_info.batch));
    ESP_REPORT_INFO(VON, "-----------------");

    // Communication channels
    ac_channel<dma_info_t> dma_read_ctrl;
    ac_channel<dma_info_t> dma_write_ctrl;
    ac_channel<dma_data_t> dma_read_chnl;
    ac_channel<dma_data_t> dma_write_chnl;

    // Testbench data
    FPDATA_IN inputs[PLM_SIZE * BATCH_MAX];
    FPDATA_OUT outputs[PLM_SIZE * BATCH_MAX];
    double gold_outputs[PLM_SIZE * BATCH_MAX];

    // Pass inputs to the accelerator
    for (unsigned i = 0; i < conf_info.batch * softmax_size; i++) {

        FPDATA_IN data_fp = (i % 32) + 0.25;

        inputs[i] = data_fp;

        ac_int<DMA_WIDTH, false> data_ac;
        ac_int<32, false> DEADBEEF = 0xdeadbeef;
        data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
        data_ac.set_slc(0, inputs[i].template slc<DATA_WIDTH>(0));

        dma_read_chnl.write(data_ac);
    }

    // Run the accelerator
    ac_channel<bool> conf_done;
    //conf_done.write(false);
    conf_done.write(true);
    softmax_cxx(debug, conf_info, conf_done, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl);

    // Fetch outputs from the accelerator
    for (unsigned i = 0; i < conf_info.batch * softmax_size; i++) {
        // DMA_WIDTH = 64
        // discard bits in the range(63,32)
        // keep bits in the range(31,0)
        ac_int<DATA_WIDTH, false> data = dma_write_chnl.read().template slc<DATA_WIDTH>(0);
        outputs[i].template set_slc<32>(0, data);
    }

    // Validation
    ESP_REPORT_INFO(VON, "-----------------");
    for (unsigned i = 0; i < conf_info.batch; i++) {
        softmax_tb(inputs + i * softmax_size, gold_outputs + i * softmax_size);
    }
    unsigned errors = 0;

    double allowed_error = 0.001;

    for (unsigned i = 0; i < conf_info.batch * softmax_size; i++) {
        float gold = gold_outputs[i];
        FPDATA_OUT data = outputs[i];

        // Calculate absolute error
        double error_it = abs_double(data.to_double() - gold);

        if (error_it > allowed_error) {
            ESP_REPORT_INFO(VON, "[%u]: %f (expected %f)", i, data.to_double(), gold);
            errors++;
        }
    }

    if (errors > 0 || debug != 0) {
        ESP_REPORT_INFO(VON, "Validation: FAIL (errors %u / total %u)", errors, PLM_SIZE);
        rc = 1;
    } else {
        ESP_REPORT_INFO(VON, "Validation: PASS");
        rc = 0;
    }
    ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, PLM_SIZE);
    ESP_REPORT_INFO(VON, "  - debug flag %u", ESP_TO_UINT32(debug));
    ESP_REPORT_INFO(VON, "-----------------");

    CCS_RETURN(rc);
}
