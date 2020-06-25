#ifndef __SHA2_256_H__
#define __SHA2_256_H__

static const uint32_t K256[64] = {
    0x428a2f98UL, 0x71374491UL, 0xb5c0fbcfUL, 0xe9b5dba5UL,
    0x3956c25bUL, 0x59f111f1UL, 0x923f82a4UL, 0xab1c5ed5UL,
    0xd807aa98UL, 0x12835b01UL, 0x243185beUL, 0x550c7dc3UL,
    0x72be5d74UL, 0x80deb1feUL, 0x9bdc06a7UL, 0xc19bf174UL,
    0xe49b69c1UL, 0xefbe4786UL, 0x0fc19dc6UL, 0x240ca1ccUL,
    0x2de92c6fUL, 0x4a7484aaUL, 0x5cb0a9dcUL, 0x76f988daUL,
    0x983e5152UL, 0xa831c66dUL, 0xb00327c8UL, 0xbf597fc7UL,
    0xc6e00bf3UL, 0xd5a79147UL, 0x06ca6351UL, 0x14292967UL,
    0x27b70a85UL, 0x2e1b2138UL, 0x4d2c6dfcUL, 0x53380d13UL,
    0x650a7354UL, 0x766a0abbUL, 0x81c2c92eUL, 0x92722c85UL,
    0xa2bfe8a1UL, 0xa81a664bUL, 0xc24b8b70UL, 0xc76c51a3UL,
    0xd192e819UL, 0xd6990624UL, 0xf40e3585UL, 0x106aa070UL,
    0x19a4c116UL, 0x1e376c08UL, 0x2748774cUL, 0x34b0bcb5UL,
    0x391c0cb3UL, 0x4ed8aa4aUL, 0x5b9cca4fUL, 0x682e6ff3UL,
    0x748f82eeUL, 0x78a5636fUL, 0x84c87814UL, 0x8cc70208UL,
    0x90befffaUL, 0xa4506cebUL, 0xbef9a3f7UL, 0xc67178f2UL };

/* See definitions here: https://tools.ietf.org/html/rfc4634 */

#define SHA256_SHR(bits, word) \
      ((word) >> (bits))

#define SHA256_ROTR(bits, word) \
      (((word) >> (bits)) | ((word) << (32-(bits))))

#define SHA256_SIGMA0(word) \
      (SHA256_ROTR( 2, word) ^ SHA256_ROTR(13, word) ^ SHA256_ROTR(22, word))

#define SHA256_SIGMA1(word) \
      (SHA256_ROTR( 6, word) ^ SHA256_ROTR(11, word) ^ SHA256_ROTR(25, word))

#define SHA256_sigma0(word) \
      (SHA256_ROTR( 7, word) ^ SHA256_ROTR(18, word) ^ SHA256_SHR( 3, word))

#define SHA256_sigma1(word) \
      (SHA256_ROTR(17, word) ^ SHA256_ROTR(19, word) ^ SHA256_SHR(10, word))

#define SHA256_Maj(x, y, z) \
    (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

#define SHA256_Ch(x, y, z)  \
    (((x) & (y)) ^ ((~(x)) & (z)))

/* There are other alternative implementations in openssl */

void sha256_block_data_order(uint32_t h[8],
                             uint32_t in_bytes,
                             uint8_t in[SHA2_MAX_BLOCK_SIZE])
{
    uint32_t X[64], tmp[8];
    uint32_t s0, s1, T1, T2;

    #pragma HLS array_partition variable=h complete
    #pragma HLS array_partition variable=tmp complete
    #pragma HLS array_partition variable=K256 cyclic factor=16
    /* #pragma HLS array_partition variable=X block factor=4 */

    for (unsigned t = 0; t < 8; ++t)
    {
        #pragma HLS unroll skip_exit_check
        tmp[t] = h[t];
    }

    for (unsigned p = 0; p < in_bytes; p += 4)
    {
        /* Considering an input of 65536 bytes. */
        #pragma HLS loop_tripcount min=1 max=256
        #pragma HLS loop_flatten off

        unsigned mem = (in_bytes.to_int() - p) >= 4 ?
                4 : (in_bytes.to_int() - p);

        for (unsigned t = 0; t < 64 * mem; t += 4)
        {
            /* Considering an input of 65536 bytes. */
            #pragma HLS loop_tripcount min=16 max=64
            #pragma HLS pipeline

            X[t >> 2]  = (uint32_t(in[(p << 6) + t + 0]) << 24)
                       | (uint32_t(in[(p << 6) + t + 1]) << 16)
                       | (uint32_t(in[(p << 6) + t + 2]) << 8)
                       | (uint32_t(in[(p << 6) + t + 3]) << 0);
        }

        for (unsigned k = 0; k < mem; ++k)
        {
            /* Considering an input of 65536 bytes. */
            #pragma HLS loop_tripcount min=1 max=4

            for (unsigned i = 0; i < 16; i++)
            {
                #pragma HLS unroll skip_exit_check
                unsigned j = (k << 4) + i;

                T1 = X[j] + tmp[7] + SHA256_SIGMA1(tmp[4]) +
                    SHA256_Ch(tmp[4], tmp[5], tmp[6]) + K256[i];

                T2 = SHA256_SIGMA0(tmp[0]) + SHA256_Maj(tmp[0], tmp[1], tmp[2]);

                for (unsigned t = 7; t >= 1; --t)
                {
                    #pragma HLS unroll skip_exit_check
                    tmp[t] = tmp[t - 1];
                }

                tmp[0] = T1 + T2;
                tmp[4] += T1;
            }

            for (unsigned i = 16; i < 64; i++)
            {
                #pragma HLS unroll skip_exit_check

                s0 = X[((i + 1) & 0x0f) + (k << 4)];
                s0 = SHA256_sigma0(s0);

                s1 = X[((i + 14) & 0x0f) + (k << 4)];
                s1 = SHA256_sigma1(s1);

                X[(i & 0xf) + (k << 4)] += s0 + s1 + X[((i + 9) & 0xf) + (k << 4)];

                T1 = X[(i & 0xf) + (k << 4)] + tmp[7] + SHA256_SIGMA1(tmp[4]) +
                        SHA256_Ch(tmp[4], tmp[5], tmp[6]) + K256[i];

                T2 = SHA256_SIGMA0(tmp[0]) + SHA256_Maj(tmp[0], tmp[1], tmp[2]);

                for (unsigned t = 7; t >= 1; --t)
                {
                    #pragma HLS unroll skip_exit_check
                    tmp[t] = tmp[t - 1];
                }

                tmp[0] = T1 + T2;
                tmp[4] += T1;
            }

            for (unsigned t = 0; t < 8; ++t)
            {
                #pragma HLS unroll skip_exit_check
                tmp[t] += h[t];
                h[t] = tmp[t];
            }
        }
    }
}

void sha256_update(uint32_t h[8],
                   uint8_t data[SHA_LBLOCK << 2],
                   uint32_t *num,
                   uint32_t in_bytes,
                   uint8_t in[SHA2_MAX_BLOCK_SIZE])
{
    uint32_t n = in_bytes >> SHA_CBLOCK_LOG;

    if (n > 0)
    {
        sha256_block_data_order(h, n, in);
        n <<= SHA_CBLOCK_LOG;
        in_bytes -= n;
    }

    if (in_bytes != 0)
    {
        for (unsigned i = 0; i < in_bytes; ++i)
        {
            /* Considering an input of 65536 bytes. */
            #pragma HLS loop_tripcount min=0 max=64
            #pragma HLS pipeline II=1

            data[i] = in[i + n];
        }

        *num = in_bytes;
    }
}

void sha256_final(uint32_t h[8],
                  uint32_t Nl,
                  uint32_t Nh,
                  uint8_t data[SHA_LBLOCK << 2],
                  uint32_t num,
                  uint32_t out_bytes,
                  uint8_t out[SHA2_MAX_DIGEST_SIZE])
{
    data[num++] = 0x80;

    if (num > (SHA_CBLOCK - 8))
    {
        if (num < SHA_CBLOCK)
        {
            for (unsigned k = 0; k < SHA_CBLOCK - num; ++k)
            {
                /* Considering an input of 65536 bytes. */
                #pragma HLS loop_tripcount min=0 max=8
                #pragma HLS unroll factor=8

                data[num + k] = 0;
            }
        }

        sha256_block_data_order(h, 1, data);
        num = 0;
    }

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

    sha256_block_data_order(h, 1, data);

    for (unsigned k = 0; k < out_bytes; k += 4)
    {
        /* Considering an output of 32 bytes. */
        #pragma HLS loop_tripcount min=8 max=8

        out[k + 0] = (h[k >> 2] >> 24) & 0xff;
        out[k + 1] = (h[k >> 2] >> 16) & 0xff;
        out[k + 2] = (h[k >> 2] >>  8) & 0xff;
        out[k + 3] = (h[k >> 2] >>  0) & 0xff;
    }
}

#endif /* __SHA2_256_H__ */
