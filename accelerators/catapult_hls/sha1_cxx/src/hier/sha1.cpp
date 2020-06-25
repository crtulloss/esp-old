#include "sha1.h"

#include <mc_scverify.h>

void body_00_15(uint32_t a,
                uint32_t *b,
                uint32_t c,
                uint32_t d,
                uint32_t e,
                uint32_t *f,
                uint32_t xi)
{
    #pragma HLS inline
    #pragma HLS latency max=1

    *f = xi + e + ((a << 5) | a >> 27) +
            0x5a827999UL + (((c ^ d) & *b) ^ d);
    *b = ((*b << 30)) | (*b >> 2);
}

void body_16_19(uint32_t a,
                uint32_t *b,
                uint32_t c,
                uint32_t d,
                uint32_t e,
                uint32_t *f,
                uint32_t *xi,
                uint32_t xa,
                uint32_t xb,
                uint32_t xc,
                uint32_t xd)
{
    #pragma HLS inline
    #pragma HLS latency max=1

    *f = xa ^ xb ^ xc ^ xd;
    *xi = (*f << 1) | (*f >> 31);
    *f = *xi + e + ((a << 5) | a >> 27) +
            0x5a827999UL + (((c ^ d) & *b) ^ d);
    *b = ((*b << 30)) | (*b >> 2);
}

void body_20_31(uint32_t a,
                uint32_t *b,
                uint32_t c,
                uint32_t d,
                uint32_t e,
                uint32_t *f,
                uint32_t *xi,
                uint32_t xa,
                uint32_t xb,
                uint32_t xc,
                uint32_t xd)
{
    #pragma HLS inline
    #pragma HLS latency max=1

    *f = xa ^ xb ^ xc ^ xd;
    *xi = ((*f << 1) | *f >> 31);
    *f = *xi + e + ((a << 5) | a >> 27) +
            0x6ed9eba1UL + (*b ^ c ^ d);
    *b = ((*b << 30)) | (*b >> 2);
}

void body_32_39(uint32_t a,
                uint32_t *b,
                uint32_t c,
                uint32_t d,
                uint32_t e,
                uint32_t *f,
                uint32_t *xa,
                uint32_t xb,
                uint32_t xc,
                uint32_t xd)
{
    #pragma HLS inline
    #pragma HLS latency max=1

    *f  = *xa ^ xb ^ xc ^ xd;
    *xa = ((*f << 1) | *f >> 31);
    *f = *xa + e + ((a << 5) | a >> 27) +
            0x6ed9eba1UL + (*b ^ c ^ d);
    *b = ((*b << 30)) | (*b >> 2);
}

void body_40_59(uint32_t a,
                uint32_t *b,
                uint32_t c,
                uint32_t d,
                uint32_t e,
                uint32_t *f,
                uint32_t *xa,
                uint32_t xb,
                uint32_t xc,
                uint32_t xd)
{
    #pragma HLS inline
    #pragma HLS latency max=1

    *f  = *xa ^ xb ^ xc ^ xd;
    *xa = ((*f << 1) | *f >> 31);
    *f = *xa + e + ((a << 5) | a >> 27) +
        0x8f1bbcdcUL + ((*b & c) | ((*b | c) & d));
    *b = ((*b << 30)) | (*b >> 2);
}

void body_60_79(uint32_t a,
                uint32_t *b,
                uint32_t c,
                uint32_t d,
                uint32_t e,
                uint32_t *f,
                uint32_t *xa,
                uint32_t xb,
                uint32_t xc,
                uint32_t xd)
{
    #pragma HLS inline
    #pragma HLS latency max=1

    *f  = *xa ^ xb ^ xc ^ xd;
    *xa = ((*f << 1) | *f >> 31);
    *f = *xa + e + ((a << 5) | a >> 27) +
        0xca62c1d6UL + (*b ^ c ^ d);
    *b = ((*b << 30)) | (*b >> 2);
}

const int UNROLL_FACTOR = 1;
const int MAX_ITERATIONS = 1024 / UNROLL_FACTOR;

void sha1_block_data_compute(uint32_t mem,
                             uint32_t h[5],
                             uint32_t XX[UNROLL_FACTOR * 16])
{
    uint32_t A, B, C, D, E, T;

    A = h[0];
    B = h[1];
    C = h[2];
    D = h[3];
    E = h[4];

BLOCK_DATA_COMPUTE_LOOP:
    for (unsigned j = 0; j < UNROLL_FACTOR * 16; j += 16)
    {
        #pragma HLS unroll

        uint32_t xx0  = XX[j + 0];
        uint32_t xx1  = XX[j + 1];
        uint32_t xx2  = XX[j + 2];
        uint32_t xx3  = XX[j + 3];
        uint32_t xx4  = XX[j + 4];
        uint32_t xx5  = XX[j + 5];
        uint32_t xx6  = XX[j + 6];
        uint32_t xx7  = XX[j + 7];
        uint32_t xx8  = XX[j + 8];
        uint32_t xx9  = XX[j + 9];
        uint32_t xx10 = XX[j + 10];
        uint32_t xx11 = XX[j + 11];
        uint32_t xx12 = XX[j + 12];
        uint32_t xx13 = XX[j + 13];
        uint32_t xx14 = XX[j + 14];
        uint32_t xx15 = XX[j + 15];

        body_00_15(A, &B, C, D, E, &T, xx0);
        body_00_15(T, &A, B, C, D, &E, xx1);
        body_00_15(E, &T, A, B, C, &D, xx2);
        body_00_15(D, &E, T, A, B, &C, xx3);
        body_00_15(C, &D, E, T, A, &B, xx4);
        body_00_15(B, &C, D, E, T, &A, xx5);
        body_00_15(A, &B, C, D, E, &T, xx6);
        body_00_15(T, &A, B, C, D, &E, xx7);
        body_00_15(E, &T, A, B, C, &D, xx8);
        body_00_15(D, &E, T, A, B, &C, xx9);
        body_00_15(C, &D, E, T, A, &B, xx10);
        body_00_15(B, &C, D, E, T, &A, xx11);
        body_00_15(A, &B, C, D, E, &T, xx12);
        body_00_15(T, &A, B, C, D, &E, xx13);
        body_00_15(E, &T, A, B, C, &D, xx14);
        body_00_15(D, &E, T, A, B, &C, xx15);

        body_16_19(C, &D, E, T, A, &B, &xx0, xx0, xx2, xx8,  xx13);
        body_16_19(B, &C, D, E, T, &A, &xx1, xx1, xx3, xx9,  xx14);
        body_16_19(A, &B, C, D, E, &T, &xx2, xx2, xx4, xx10, xx15);
        body_16_19(T, &A, B, C, D, &E, &xx3, xx3, xx5, xx11, xx0);

        body_20_31(E, &T, A, B, C, &D, &xx4,  xx4,  xx6,  xx12, xx1);
        body_20_31(D, &E, T, A, B, &C, &xx5,  xx5,  xx7,  xx13, xx2);
        body_20_31(C, &D, E, T, A, &B, &xx6,  xx6,  xx8,  xx14, xx3);
        body_20_31(B, &C, D, E, T, &A, &xx7,  xx7,  xx9,  xx15, xx4);
        body_20_31(A, &B, C, D, E, &T, &xx8,  xx8,  xx10, xx0,  xx5);
        body_20_31(T, &A, B, C, D, &E, &xx9,  xx9,  xx11, xx1,  xx6);
        body_20_31(E, &T, A, B, C, &D, &xx10, xx10, xx12, xx2,  xx7);
        body_20_31(D, &E, T, A, B, &C, &xx11, xx11, xx13, xx3,  xx8);
        body_20_31(C, &D, E, T, A, &B, &xx12, xx12, xx14, xx4,  xx9);
        body_20_31(B, &C, D, E, T, &A, &xx13, xx13, xx15, xx5,  xx10);
        body_20_31(A, &B, C, D, E, &T, &xx14, xx14, xx0,  xx6,  xx11);
        body_20_31(T, &A, B, C, D, &E, &xx15, xx15, xx1,  xx7,  xx12);

        body_32_39(E, &T, A, B, C, &D, &xx0, xx2, xx8,  xx13);
        body_32_39(D, &E, T, A, B, &C, &xx1, xx3, xx9,  xx14);
        body_32_39(C, &D, E, T, A, &B, &xx2, xx4, xx10, xx15);
        body_32_39(B, &C, D, E, T, &A, &xx3, xx5, xx11, xx0);
        body_32_39(A, &B, C, D, E, &T, &xx4, xx6, xx12, xx1);
        body_32_39(T, &A, B, C, D, &E, &xx5, xx7, xx13, xx2);
        body_32_39(E, &T, A, B, C, &D, &xx6, xx8, xx14, xx3);
        body_32_39(D, &E, T, A, B, &C, &xx7, xx9, xx15, xx4);

        body_40_59(C, &D, E, T, A, &B, &xx8,  xx10, xx0,  xx5);
        body_40_59(B, &C, D, E, T, &A, &xx9,  xx11, xx1,  xx6);
        body_40_59(A, &B, C, D, E, &T, &xx10, xx12, xx2,  xx7);
        body_40_59(T, &A, B, C, D, &E, &xx11, xx13, xx3,  xx8);
        body_40_59(E, &T, A, B, C, &D, &xx12, xx14, xx4,  xx9);
        body_40_59(D, &E, T, A, B, &C, &xx13, xx15, xx5,  xx10);
        body_40_59(C, &D, E, T, A, &B, &xx14, xx0,  xx6,  xx11);
        body_40_59(B, &C, D, E, T, &A, &xx15, xx1,  xx7,  xx12);
        body_40_59(A, &B, C, D, E, &T, &xx0,  xx2,  xx8,  xx13);
        body_40_59(T, &A, B, C, D, &E, &xx1,  xx3,  xx9,  xx14);
        body_40_59(E, &T, A, B, C, &D, &xx2,  xx4,  xx10, xx15);
        body_40_59(D, &E, T, A, B, &C, &xx3,  xx5,  xx11, xx0);
        body_40_59(C, &D, E, T, A, &B, &xx4,  xx6,  xx12, xx1);
        body_40_59(B, &C, D, E, T, &A, &xx5,  xx7,  xx13, xx2);
        body_40_59(A, &B, C, D, E, &T, &xx6,  xx8,  xx14, xx3);
        body_40_59(T, &A, B, C, D, &E, &xx7,  xx9,  xx15, xx4);
        body_40_59(E, &T, A, B, C, &D, &xx8,  xx10, xx0,  xx5);
        body_40_59(D, &E, T, A, B, &C, &xx9,  xx11, xx1,  xx6);
        body_40_59(C, &D, E, T, A, &B, &xx10, xx12, xx2,  xx7);
        body_40_59(B, &C, D, E, T, &A, &xx11, xx13, xx3,  xx8);

        body_60_79(A, &B, C, D, E, &T, &xx12, xx14, xx4,  xx9);
        body_60_79(T, &A, B, C, D, &E, &xx13, xx15, xx5,  xx10);
        body_60_79(E, &T, A, B, C, &D, &xx14, xx0,  xx6,  xx11);
        body_60_79(D, &E, T, A, B, &C, &xx15, xx1,  xx7,  xx12);
        body_60_79(C, &D, E, T, A, &B, &xx0,  xx2,  xx8,  xx13);
        body_60_79(B, &C, D, E, T, &A, &xx1,  xx3,  xx9,  xx14);
        body_60_79(A, &B, C, D, E, &T, &xx2,  xx4,  xx10, xx15);
        body_60_79(T, &A, B, C, D, &E, &xx3,  xx5,  xx11, xx0);
        body_60_79(E, &T, A, B, C, &D, &xx4,  xx6,  xx12, xx1);
        body_60_79(D, &E, T, A, B, &C, &xx5,  xx7,  xx13, xx2);
        body_60_79(C, &D, E, T, A, &B, &xx6,  xx8,  xx14, xx3);
        body_60_79(B, &C, D, E, T, &A, &xx7,  xx9,  xx15, xx4);
        body_60_79(A, &B, C, D, E, &T, &xx8,  xx10, xx0,  xx5);
        body_60_79(T, &A, B, C, D, &E, &xx9,  xx11, xx1,  xx6);
        body_60_79(E, &T, A, B, C, &D, &xx10, xx12, xx2,  xx7);
        body_60_79(D, &E, T, A, B, &C, &xx11, xx13, xx3,  xx8);
        body_60_79(C, &D, E, T, A, &B, &xx12, xx14, xx4,  xx9);
        body_60_79(B, &C, D, E, T, &A, &xx13, xx15, xx5,  xx10);
        body_60_79(A, &B, C, D, E, &T, &xx14, xx0,  xx6,  xx11);
        body_60_79(T, &A, B, C, D, &E, &xx15, xx1,  xx7,  xx12);

        if (j < (mem << 4))
        {
            h[0] += E;
            h[1] += T;
            h[2] += A;
            h[3] += B;
            h[4] += C;

            A = h[0];
            B = h[1];
            C = h[2];
            D = h[3];
            E = h[4];
        }
    }
}

void sha1_block_data_load(uint32_t p,
                          uint32_t mem,
                          uint32_t XX[UNROLL_FACTOR * 16],
                          uint8_t in[SHA1_MAX_BLOCK_SIZE])
{
BLOCK_DATA_LOAD:
#ifdef C_SIMULATION
    for (unsigned i = 0; i < mem * 64; i += 4)
#else /* ! C_SIMULATION */
    for (unsigned i = 0; i < UNROLL_FACTOR * 64; i += 4)
#endif /* C_SIMULATION */
    {
        #pragma HLS unroll complete

        XX[i >> 2] = (uint32_t(in[(p << 6) + i + 0]) << 24)
                   | (uint32_t(in[(p << 6) + i + 1]) << 16)
                   | (uint32_t(in[(p << 6) + i + 2]) <<  8)
                   | (uint32_t(in[(p << 6) + i + 3]) <<  0);
    }
}

void sha1_block_data_order(uint32_t h[5],
                           uint32_t in_bytes,
                           uint8_t in[SHA1_MAX_BLOCK_SIZE])
{
    #pragma HLS function_instantiate variable=in_bytes

BLOCK_DATA_ORDER_LOOP:
    for (uint32_t p = 0; p < in_bytes; p += UNROLL_FACTOR)
    {
        /* Considering an input of 65536 bytes. */
        #pragma HLS loop_tripcount min=1 max=MAX_ITERATIONS
        #pragma HLS pipeline rewind

        uint32_t XX[UNROLL_FACTOR * 16];
        uint32_t len = (in_bytes - p) >= int32_t(UNROLL_FACTOR) ?
                uint32_t(UNROLL_FACTOR) : uint32_t(in_bytes - p);

        sha1_block_data_load(p, len, XX, in);
        sha1_block_data_compute(len, h, XX);
    }
}

void sha1_update(uint32_t h[5],
                 uint8_t data[SHA_LBLOCK << 2],
                 uint32_t *num,
                 uint32_t in_bytes,
                 uint8_t in[SHA1_MAX_BLOCK_SIZE])
{
    uint32_t n = in_bytes >> SHA_CBLOCK_LOG;

    if (n > 0)
    {
        sha1_block_data_order(h, n, in);
        n <<= SHA_CBLOCK_LOG;
        in_bytes -= n;
    }

    if (in_bytes != 0)
    {
UPDATE_LOOP:
        for (unsigned i = 0; i < in_bytes; ++i)
        {
            /* Considering an input of 65536 bytes. */
            #pragma HLS loop_tripcount min=1 max=UNROLL_FACTOR*16
            #pragma HLS pipeline II=1

            data[i] = in[i + n];
        }

        *num = in_bytes;
    }
}

void sha1_final(uint32_t h[5],
                uint32_t Nl,
                uint32_t Nh,
                uint8_t data[SHA_LBLOCK << 2],
                uint32_t num,
                uint8_t out[SHA1_DIGEST_LENGTH])
{
    data[num++] = 0x80;

    if (num > (SHA_CBLOCK - 8))
    {
        if (num < SHA_CBLOCK)
        {
FINAL_1_LOOP:
            for (unsigned k = 0; k < SHA_CBLOCK - num; ++k)
            {
                /* Considering an input of 65536 bytes. */
                #pragma HLS loop_tripcount min=0 max=8
                #pragma HLS unroll factor=8

                data[num + k] = 0;
            }
        }

        sha1_block_data_order(h, 1, data);
        num = 0;
    }
FINAL_2_LOOP:
    for (unsigned k = 0; k < SHA_CBLOCK - 8 - num; ++k)
    {
        /* Considering an input of 65536 bytes. */
        #pragma HLS loop_tripcount min=0 max=56
        #pragma HLS unroll factor=8

        data[num + k] = 0;
    }

    data[(SHA_CBLOCK - 8) + 0] = ((Nh >> 24) & 0xff);
    data[(SHA_CBLOCK - 8) + 1] = ((Nh >> 16) & 0xff);
    data[(SHA_CBLOCK - 8) + 2] = ((Nh >>  8) & 0xff);
    data[(SHA_CBLOCK - 8) + 3] = ((Nh >>  0) & 0xff);

    data[(SHA_CBLOCK - 8) + 4] = ((Nl >> 24) & 0xff);
    data[(SHA_CBLOCK - 8) + 5] = ((Nl >> 16) & 0xff);
    data[(SHA_CBLOCK - 8) + 6] = ((Nl >>  8) & 0xff);
    data[(SHA_CBLOCK - 8) + 7] = ((Nl >>  0) & 0xff);

    sha1_block_data_order(h, 1, data);

FINAL_3_LOOP:
    for (unsigned k = 0; k < SHA1_DIGEST_LENGTH; k += 4)
    {
        /* Considering an output of 20 bytes. */
        #pragma HLS loop_tripcount min=5 max=5

        out[k + 0] = (h[k >> 2] >> 24) & 0xff;
        out[k + 1] = (h[k >> 2] >> 16) & 0xff;
        out[k + 2] = (h[k >> 2] >>  8) & 0xff;
        out[k + 3] = (h[k >> 2] >>  0) & 0xff;
    }
}

void sha1_core(
          uint32_t in_bytes,
          uint8_t in[SHA1_MAX_BLOCK_SIZE],
          uint8_t out[SHA1_DIGEST_LENGTH])
{
    uint32_t h[5];
    uint32_t num = 0;
    uint8_t d[SHA_LBLOCK << 2];
    uint32_t Nl = (in_bytes << 3);
    uint32_t Nh = (in_bytes >> 29);

    h[0] = 0x67452301UL;
    h[1] = 0xefcdab89UL;
    h[2] = 0x98badcfeUL;
    h[3] = 0x10325476UL;
    h[4] = 0xc3d2e1f0UL;

    if (in_bytes != 0)
        sha1_update(h, d, &num, in_bytes, in);

    sha1_final(h, Nl, Nh, d, num, out);
}


//#pragma hls_design top
#ifdef C_SIMULATION
void sha1_cxx(
#else
void CCS_BLOCK(sha1_cxx)(
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

    ESP_REPORT_INFO(VOFF, "conf_info.batch = %u, conf_info.in_bytes =  %u", ESP_TO_UINT32(batch), ESP_TO_UINT32(in_bytes));

    dma_read_data_length = in_bytes;
    dma_write_data_length = SHA1_DIGEST_LENGTH;

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
            for (uint16_t i = 0; i < SHA1_MAX_BLOCK_SIZE; i+=8) {

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

        sha1_core(in_bytes, plm_input.data, plm_output.data);

        // Configure DMA write channle (CTRL)
        dma_write_data_index = (dma_read_data_length * batch) + dma_write_data_length * b;
        dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        bool dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
        do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VOFF, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
            for (uint16_t i = 0; i < SHA1_DIGEST_LENGTH; i+=8) {

                //if (i >= dma_write_data_length) break;

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
