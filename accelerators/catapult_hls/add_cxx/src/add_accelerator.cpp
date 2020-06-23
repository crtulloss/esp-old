#include "add_accelerator.h"

#include <mc_scverify.h>

void add_accelerator_core(
    uint32_t length,
    uint64_t input1[PLM_SIZE],
    uint64_t input2[PLM_SIZE],
    uint64_t output[PLM_SIZE],
    uint32_t &ret)
{
	for (uint32_t i = 0; i < PLM_SIZE; ++i)
    {
        if (i >= length) break;
        output[i] = input1[i] + input2[i];
        ESP_REPORT_INFO(VOFF, "output[%u] = %llu (input1[%u]: %llu, input2[%u]: %llu)", ESP_TO_UINT32(i), ESP_TO_UINT64(output[i]), ESP_TO_UINT32(i), ESP_TO_UINT64(input1[i]), ESP_TO_UINT32(i), ESP_TO_UINT64(input2[i]));
    }

    ret = 0;
}

#pragma hls_design top
#ifdef C_SIMULATION
void add_accelerator_cxx(
#else
void CCS_BLOCK(add_accelerator_cxx)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    // Bookkeeping variables
    uint32_t dma_read_data_index1 = 0;
    uint32_t dma_read_data_index2 = 0;
    uint32_t dma_read_data_length = 0;
    uint32_t dma_write_data_index = 0;
    uint32_t dma_write_data_length = 0;
    bool dma_read_ctrl_done = false;

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};

    uint32_t batch = 0;
    uint32_t length = 0;

    // Private Local Memories
    plm_t plm_input1;
    plm_t plm_input2;
    plm_t plm_output;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    conf_info_t conf_info_reg = conf_info.read();
    batch = conf_info_reg.batch;
    length = conf_info_reg.length;

    ESP_REPORT_INFO(VON, "conf_info.batch = %u, conf_info.length =  %u", ESP_TO_UINT32(batch), ESP_TO_UINT32(length));

    dma_read_data_length = length;
    dma_write_data_length = length;

BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_read_data_index1 = dma_read_data_length * b;
        dma_read_info = {dma_read_data_index1, dma_read_data_length, DMA_SIZE};
        dma_read_ctrl_done = false;
LOAD_CTRL_1_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_1_LOOP:
            for (uint16_t i = 0; i < PLM_SIZE; i++) {

                if (i >= dma_read_data_length) break;

                DATA_WORD data;
#ifndef __SYNTHESIS__
                while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
                data = dma_read_chnl.read();

                plm_input1.data[i] = data;

                ESP_REPORT_INFO(VOFF, "plm_input1[%u] = %llu", ESP_TO_UINT32(i), data.to_uint64());
            }
        }

        // Configure DMA read channel (CTRL)
        dma_read_data_index2 = dma_read_data_length * b;
        dma_read_info = {dma_read_data_index2, dma_read_data_length, DMA_SIZE};
        dma_read_ctrl_done = false;
LOAD_CTRL_2_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_2_LOOP:
            for (uint16_t i = 0; i < PLM_SIZE; i++) {

                if (i >= dma_read_data_length) break;

                DATA_WORD data;
#ifndef __SYNTHESIS__
                while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
                data = dma_read_chnl.read();

                plm_input2.data[i] = data;

                ESP_REPORT_INFO(VOFF, "plm_input2[%u] = %llu", ESP_TO_UINT32(i), data.to_uint64());
            }
        }

        uint32_t ret = 0; // ignored

        add_accelerator_core(length, plm_input1.data, plm_input2.data, plm_output.data, ret);

        // Configure DMA write channle (CTRL)
        dma_write_data_index = (dma_write_data_length * batch) + dma_write_data_length * b;
        dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        bool dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
        do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
            for (uint16_t i = 0; i < PLM_SIZE; i++) {

                if (i >= dma_write_data_length) break;

                DATA_WORD data = plm_output.data[i];

                dma_write_chnl.write(data);

                ESP_REPORT_INFO(VOFF, "plm_output[%u] = %llu", ESP_TO_UINT32(i), data.to_uint64());
            }
        }
    }

    acc_done.sync_out();
}
