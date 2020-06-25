#include "sha2.h"
#include "sha2_256.h"
#include "sha2_512.h"

#include <mc_scverify.h>

void sha224_256(uint32_t in_bytes,
                uint32_t out_bytes,
                uint8_t in[SHA2_MAX_BLOCK_SIZE],
                uint8_t out[SHA2_MAX_DIGEST_SIZE])
{
    uint32_t h[8];
    uint32_t num = 0;
    uint8_t d[SHA_LBLOCK << 2];
    uint32_t Nl = (in_bytes << 3);
    uint32_t Nh = (in_bytes >> 29);

    #pragma HLS array_partition variable=h complete
    #pragma HLS array_partition variable=d cyclic factor=4

    if (out_bytes == SHA224_DIGEST_LENGTH)
    {
    	h[0] = 0xc1059ed8UL;
    	h[1] = 0x367cd507UL;
    	h[2] = 0x3070dd17UL;
    	h[3] = 0xf70e5939UL;
    	h[4] = 0xffc00b31UL;
    	h[5] = 0x68581511UL;
    	h[6] = 0x64f98fa7UL;
    	h[7] = 0xbefa4fa4UL;
    }

    if (out_bytes == SHA256_DIGEST_LENGTH)
    {
        h[0] = 0x6a09e667UL;
        h[1] = 0xbb67ae85UL;
        h[2] = 0x3c6ef372UL;
        h[3] = 0xa54ff53aUL;
        h[4] = 0x510e527fUL;
        h[5] = 0x9b05688cUL;
        h[6] = 0x1f83d9abUL;
        h[7] = 0x5be0cd19UL;
    }

    if (in_bytes != 0)
        sha256_update(h, d, &num, in_bytes, in);

    sha256_final(h, Nl, Nh, d, num, out_bytes, out);
}

void sha384_512(uint32_t in_bytes,
                uint32_t out_bytes,
                uint8_t in[SHA2_MAX_BLOCK_SIZE],
                uint8_t out[SHA2_MAX_DIGEST_SIZE])
{
    uint64_t h[8];
    uint32_t num = 0;
    uint8_t d[SHA_LBLOCK << 3];
    uint64_t Nl = ((uint64_t) in_bytes << 3);
    uint64_t Nh = ((uint64_t) in_bytes >> 61);

    #pragma HLS array_partition variable=h complete
    #pragma HLS array_partition variable=d cyclic factor=4

    if (out_bytes == SHA384_DIGEST_LENGTH)
    {
        h[0] = 0xcbbb9d5dc1059ed8ULL;
        h[1] = 0x629a292a367cd507ULL;
        h[2] = 0x9159015a3070dd17ULL;
        h[3] = 0x152fecd8f70e5939ULL;
        h[4] = 0x67332667ffc00b31ULL;
        h[5] = 0x8eb44a8768581511ULL;
        h[6] = 0xdb0c2e0d64f98fa7ULL;
        h[7] = 0x47b5481dbefa4fa4ULL;
    }

    if (out_bytes == SHA512_DIGEST_LENGTH)
    {
        h[0] = 0x6a09e667f3bcc908ULL;
        h[1] = 0xbb67ae8584caa73bULL;
        h[2] = 0x3c6ef372fe94f82bULL;
        h[3] = 0xa54ff53a5f1d36f1ULL;
        h[4] = 0x510e527fade682d1ULL;
        h[5] = 0x9b05688c2b3e6c1fULL;
        h[6] = 0x1f83d9abfb41bd6bULL;
        h[7] = 0x5be0cd19137e2179ULL;
    }

    if (in_bytes != 0)
        sha512_update(h, d, &num, in_bytes, in);

    sha512_final(h, Nl, Nh, d, num, out_bytes, out);
}

void sha2_core(uint32_t in_bytes,
          uint32_t out_bytes,
          uint8_t in[SHA2_MAX_BLOCK_SIZE],
          uint8_t out[SHA2_MAX_DIGEST_SIZE])
{
    if (out_bytes == SHA224_DIGEST_LENGTH ||
        out_bytes == SHA256_DIGEST_LENGTH)
    {
    	sha224_256(in_bytes, out_bytes, in, out);
    }

    if (out_bytes == SHA384_DIGEST_LENGTH ||
        out_bytes == SHA512_DIGEST_LENGTH)
    {
        sha384_512(in_bytes, out_bytes, in, out);
    }
}


#pragma hls_design top
#ifdef C_SIMULATION
void sha2_cxx(
#else
void CCS_BLOCK(sha2_cxx)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    // Bookkeeping variables
    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = 0;
    uint32_t dma_write_data_index = 0;
    uint32_t dma_write_data_length = 0;
    bool dma_read_ctrl_done = false;

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};

    uint32_t batch = 0;
    uint32_t in_bytes = 0;
    uint32_t out_bytes = 0;

    // Private Local Memories
    plm_in_t plm_input;
    plm_out_t plm_output;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    conf_info_t conf_info_reg = conf_info.read();
    batch = conf_info_reg.batch;
    in_bytes = conf_info_reg.in_bytes;
    out_bytes = conf_info_reg.out_bytes;

    ESP_REPORT_INFO(VOFF, "conf_info.batch = %u, conf_info.in_bytes =  %u, conf_info.out_bytes =  %u", ESP_TO_UINT32(batch), ESP_TO_UINT32(in_bytes), ESP_TO_UINT32(out_bytes));

    dma_read_data_length = in_bytes;
    dma_write_data_length = out_bytes;

BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_read_data_index = dma_read_data_length * b;
        dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VOFF, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_LOOP:
            for (uint16_t i = 0; i < SHA2_MAX_BLOCK_SIZE; i+=8) {

                if (i >= dma_read_data_length) break;

                dma_data_t dma_data;
#ifndef __SYNTHESIS__
                while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
                dma_data = dma_read_chnl.read();

                data_t d0 = dma_data.template slc<DATA_WIDTH>(0);
                data_t d1 = dma_data.template slc<DATA_WIDTH>(8);
                data_t d2 = dma_data.template slc<DATA_WIDTH>(16);
                data_t d3 = dma_data.template slc<DATA_WIDTH>(24);
                data_t d4 = dma_data.template slc<DATA_WIDTH>(32);
                data_t d5 = dma_data.template slc<DATA_WIDTH>(40);
                data_t d6 = dma_data.template slc<DATA_WIDTH>(48);
                data_t d7 = dma_data.template slc<DATA_WIDTH>(56);

                plm_input.data[i+0] = d0;
                plm_input.data[i+1] = d1;
                plm_input.data[i+2] = d2;
                plm_input.data[i+3] = d3;
                plm_input.data[i+4] = d4;
                plm_input.data[i+5] = d5;
                plm_input.data[i+6] = d6;
                plm_input.data[i+7] = d7;

                ESP_REPORT_INFO(VOFF, "plm_input1[%u] = 0x%016llX", ESP_TO_UINT32(i), dma_data.to_uint64());
                ESP_REPORT_INFO(VOFF, "plm_input1[%u, 0] = 0x%02X", ESP_TO_UINT32(i), d0.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_input1[%u, 1] = 0x%02X", ESP_TO_UINT32(i), d1.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_input1[%u, 2] = 0x%02X", ESP_TO_UINT32(i), d2.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_input1[%u, 3] = 0x%02X", ESP_TO_UINT32(i), d3.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_input1[%u, 4] = 0x%02X", ESP_TO_UINT32(i), d4.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_input1[%u, 5] = 0x%02X", ESP_TO_UINT32(i), d5.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_input1[%u, 6] = 0x%02X", ESP_TO_UINT32(i), d6.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_input1[%u, 7] = 0x%02X", ESP_TO_UINT32(i), d7.to_uint());
            }
        }

        sha2_core(in_bytes, out_bytes, plm_input.data, plm_output.data);

        // Configure DMA write channle (CTRL)
        dma_write_data_index = (dma_read_data_length * batch) + dma_write_data_length * b;
        dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        bool dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
        do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VOFF, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
            for (uint16_t i = 0; i < SHA2_MAX_DIGEST_SIZE; i+=8) {

                if (i >= dma_write_data_length) break;

                data_t d0 = (i+0 < dma_write_data_length) ? plm_output.data[i+0] : data_t(0);
                data_t d1 = (i+1 < dma_write_data_length) ? plm_output.data[i+1] : data_t(0);
                data_t d2 = (i+2 < dma_write_data_length) ? plm_output.data[i+2] : data_t(0);
                data_t d3 = (i+3 < dma_write_data_length) ? plm_output.data[i+3] : data_t(0);
                data_t d4 = (i+4 < dma_write_data_length) ? plm_output.data[i+4] : data_t(0);
                data_t d5 = (i+5 < dma_write_data_length) ? plm_output.data[i+5] : data_t(0);
                data_t d6 = (i+6 < dma_write_data_length) ? plm_output.data[i+6] : data_t(0);
                data_t d7 = (i+7 < dma_write_data_length) ? plm_output.data[i+7] : data_t(0);

                dma_data_t data;

                data.set_slc<DATA_WIDTH>(0, d0);
                data.set_slc<DATA_WIDTH>(8, d1);
                data.set_slc<DATA_WIDTH>(16, d2);
                data.set_slc<DATA_WIDTH>(24, d3);
                data.set_slc<DATA_WIDTH>(32, d4);
                data.set_slc<DATA_WIDTH>(40, d5);
                data.set_slc<DATA_WIDTH>(48, d6);
                data.set_slc<DATA_WIDTH>(56, d7);

                ESP_REPORT_INFO(VOFF, "plm_output[%u] = 0x%016llX", ESP_TO_UINT32(i), data.to_uint64());
                ESP_REPORT_INFO(VOFF, "plm_output[%u, 0] = 0x%02X", ESP_TO_UINT32(i), d0.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_output[%u, 1] = 0x%02X", ESP_TO_UINT32(i), d1.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_output[%u, 2] = 0x%02X", ESP_TO_UINT32(i), d2.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_output[%u, 3] = 0x%02X", ESP_TO_UINT32(i), d3.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_output[%u, 4] = 0x%02X", ESP_TO_UINT32(i), d4.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_output[%u, 5] = 0x%02X", ESP_TO_UINT32(i), d5.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_output[%u, 6] = 0x%02X", ESP_TO_UINT32(i), d6.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_output[%u, 7] = 0x%02X", ESP_TO_UINT32(i), d7.to_uint());

                dma_write_chnl.write(data);
            }
        }
    }

    acc_done.sync_out();
}
