#ifndef __SHA2_512_H__
#define __SHA2_512_H__

static const uint64_t K512[80] = {
    0x428a2f98d728ae22ULL, 0x7137449123ef65cdULL, 0xb5c0fbcfec4d3b2fULL, 0xe9b5dba58189dbbcULL,
    0x3956c25bf348b538ULL, 0x59f111f1b605d019ULL, 0x923f82a4af194f9bULL, 0xab1c5ed5da6d8118ULL,
    0xd807aa98a3030242ULL, 0x12835b0145706fbeULL, 0x243185be4ee4b28cULL, 0x550c7dc3d5ffb4e2ULL,
    0x72be5d74f27b896fULL, 0x80deb1fe3b1696b1ULL, 0x9bdc06a725c71235ULL, 0xc19bf174cf692694ULL,
    0xe49b69c19ef14ad2ULL, 0xefbe4786384f25e3ULL, 0x0fc19dc68b8cd5b5ULL, 0x240ca1cc77ac9c65ULL,
    0x2de92c6f592b0275ULL, 0x4a7484aa6ea6e483ULL, 0x5cb0a9dcbd41fbd4ULL, 0x76f988da831153b5ULL,
    0x983e5152ee66dfabULL, 0xa831c66d2db43210ULL, 0xb00327c898fb213fULL, 0xbf597fc7beef0ee4ULL,
    0xc6e00bf33da88fc2ULL, 0xd5a79147930aa725ULL, 0x06ca6351e003826fULL, 0x142929670a0e6e70ULL,
    0x27b70a8546d22ffcULL, 0x2e1b21385c26c926ULL, 0x4d2c6dfc5ac42aedULL, 0x53380d139d95b3dfULL,
    0x650a73548baf63deULL, 0x766a0abb3c77b2a8ULL, 0x81c2c92e47edaee6ULL, 0x92722c851482353bULL,
    0xa2bfe8a14cf10364ULL, 0xa81a664bbc423001ULL, 0xc24b8b70d0f89791ULL, 0xc76c51a30654be30ULL,
    0xd192e819d6ef5218ULL, 0xd69906245565a910ULL, 0xf40e35855771202aULL, 0x106aa07032bbd1b8ULL,
    0x19a4c116b8d2d0c8ULL, 0x1e376c085141ab53ULL, 0x2748774cdf8eeb99ULL, 0x34b0bcb5e19b48a8ULL,
    0x391c0cb3c5c95a63ULL, 0x4ed8aa4ae3418acbULL, 0x5b9cca4f7763e373ULL, 0x682e6ff3d6b2b8a3ULL,
    0x748f82ee5defb2fcULL, 0x78a5636f43172f60ULL, 0x84c87814a1f0ab72ULL, 0x8cc702081a6439ecULL,
    0x90befffa23631e28ULL, 0xa4506cebde82bde9ULL, 0xbef9a3f7b2c67915ULL, 0xc67178f2e372532bULL,
    0xca273eceea26619cULL, 0xd186b8c721c0c207ULL, 0xeada7dd6cde0eb1eULL, 0xf57d4f7fee6ed178ULL,
    0x06f067aa72176fbaULL, 0x0a637dc5a2c898a6ULL, 0x113f9804bef90daeULL, 0x1b710b35131c471bULL,
    0x28db77f523047d84ULL, 0x32caab7b40c72493ULL, 0x3c9ebe0a15c9bebcULL, 0x431d67c49c100d4cULL,
    0x4cc5d4becb3e42b6ULL, 0x597f299cfc657e2aULL, 0x5fcb6fab3ad6faecULL, 0x6c44198c4a475817ULL };

/* See definitions here: https://tools.ietf.org/html/rfc4634 */

#define SHA512_SHR(bits, word) \
     (((uint64_t)(word)) >> (bits))

#define SHA512_ROTR(bits, word) \
    ((((uint64_t)(word)) >> (bits)) | \
    (((uint64_t)(word)) << (64-(bits))))

#define SHA512_SIGMA0(word) \
     (SHA512_ROTR(28, word) ^ SHA512_ROTR(34, word) ^ SHA512_ROTR(39, word))

#define SHA512_SIGMA1(word) \
     (SHA512_ROTR(14, word) ^ SHA512_ROTR(18, word) ^ SHA512_ROTR(41, word))

#define SHA512_sigma0(word) \
     (SHA512_ROTR( 1, word) ^ SHA512_ROTR( 8, word) ^ SHA512_SHR( 7, word))

#define SHA512_sigma1(word) \
     (SHA512_ROTR(19, word) ^ SHA512_ROTR(61, word) ^ SHA512_SHR( 6, word))

#define SHA512_Maj(x,y,z) \
    (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

#define SHA512_Ch(x, y, z) \
    (((x) & (y)) ^ ((~(x)) & (z)))

/* There are other alternative implementations in openssl */

void sha512_block_data_order(uint64_t h[8],
                             uint32_t in_bytes,
                             uint8_t in[SHA2_MAX_BLOCK_SIZE])
{
    uint64_t A, E;
    uint64_t X[9 + 80];
    uint64_t T[64], T1, T2;

    #pragma HLS array_partition variable=h complete
    #pragma HLS array_partition variable=X cyclic factor=4
    #pragma HLS array_partition variable=K512 cyclic factor=4

    for (unsigned p = 0; p < in_bytes; p += 4)
    {
        /* Considering an input of 65536 bytes. */
        #pragma HLS loop_tripcount min=1 max=128
        #pragma HLS loop_flatten off

        unsigned mem = (in_bytes.to_int() - p) >= 4 ?
            4 : (in_bytes.to_int() - p);

        for (unsigned t = 0; t < 128 * mem; t += 8)
        {
            /* Considering an input of 65536 bytes. */
            #pragma HLS loop_tripcount min=16 max=64
            #pragma HLS pipeline

            T[t >> 3] = (((uint64_t) in[(p << 7) + t + 0]) << 56)
                      | (((uint64_t) in[(p << 7) + t + 1]) << 48)
                      | (((uint64_t) in[(p << 7) + t + 2]) << 40)
                      | (((uint64_t) in[(p << 7) + t + 3]) << 32)
                      | (((uint64_t) in[(p << 7) + t + 4]) << 24)
                      | (((uint64_t) in[(p << 7) + t + 5]) << 16)
                      | (((uint64_t) in[(p << 7) + t + 6]) <<  8)
                      | (((uint64_t) in[(p << 7) + t + 7]) <<  0);
        }

        for (unsigned k = 0; k < mem; ++k)
        {
            /* Considering an input of 65536 bytes. */
            #pragma HLS loop_tripcount min=1 max=4
            #pragma HLS loop_merge

            A = h[0];
            E = h[4];

            for (unsigned t = 1; t < 8; ++t)
            {
                #pragma HLS unroll skip_exit_check

                X[80 + t] = h[t];
            }

            for (unsigned i = 0; i < 16; i++)
            {
                #pragma HLS unroll factor=16

                T1 = T[(k << 4) + i];
                X[80 - i] = A;
                X[84 - i] = E;
                X[88 - i] = T1;

                T1 += X[87 - i] + SHA512_SIGMA1(E) + SHA512_Ch(E,
                        X[85 - i], X[86 - i]) + K512[i];

                A = T1 + SHA512_SIGMA0(A) + SHA512_Maj(A, X[81 - i], X[82 - i]);
                E = T1 + X[83 - i];
            }

            for (unsigned i = 0; i < 64; i++)
            {
                #pragma HLS unroll factor=16

                T2  = SHA512_sigma0(X[87 - i]);
                T2 += SHA512_sigma1(X[74 - i]);
                T2 += X[88 - i] + X[79 - i];

                X[64 - i] = A;
                X[68 - i] = E;
                X[72 - i] = T2;

                T2 += X[71 - i] + SHA512_SIGMA1(E) + SHA512_Ch(E,
                        X[69 - i], X[70 - i]) + K512[i + 16];

                A = T2 + SHA512_SIGMA0(A) + SHA512_Maj(A, X[65 - i], X[66 - i]);
                E = T2 + X[67 - i];
            }

            h[1] += X[1];
            h[2] += X[2];
            h[3] += X[3];
            h[5] += X[5];
            h[6] += X[6];
            h[7] += X[7];
            h[0] += A;
            h[4] += E;
        }
    }
}

void sha512_update(uint64_t h[8],
                   uint8_t data[SHA_LBLOCK << 3],
                   uint32_t *num,
                   uint32_t in_bytes,
                   uint8_t in[SHA2_MAX_BLOCK_SIZE])
{
    uint32_t n = in_bytes >> SHA_LBLOCK8_LOG;

    if (n > 0)
    {
        sha512_block_data_order(h, n, in);
        n <<= SHA_LBLOCK8_LOG;
        in_bytes -= n;
    }

    if (in_bytes != 0)
    {
        for (unsigned i = 0; i < in_bytes; ++i)
        {
            /* Considering an input of 65536 bytes. */
            #pragma HLS loop_tripcount min=0 max=128
            #pragma HLS pipeline II=1

            data[i] = in[i + n];
        }

        *num = in_bytes;
    }
}

void sha512_final(uint64_t h[8],
                  uint64_t Nl,
                  uint64_t Nh,
                  uint8_t data[SHA_LBLOCK << 3],
                  uint32_t num,
                  uint32_t out_bytes,
                  uint8_t out[SHA2_MAX_DIGEST_SIZE])
{
    data[num++] = 0x80;

    if (num > ((SHA_LBLOCK << 3) - 16))
    {
        if (num < (SHA_LBLOCK << 3))
        {
            for (unsigned k = 0; k < (SHA_LBLOCK << 3) - num; ++k)
            {
                /* Considering an input of 65536 bytes. */
                #pragma HLS loop_tripcount min=0 max=16
                #pragma HLS unroll factor=16

                data[num + k] = 0;
            }
        }

        sha512_block_data_order(h, 1, data);
        num = 0;
    }

    for (unsigned k = 0; k < (SHA_LBLOCK << 3) - 16 - num; ++k)
    {
        /* Considering an input of 65536 bytes. */
        #pragma HLS loop_tripcount min=0 max=112
        #pragma HLS unroll factor=16

        data[num + k] = 0;
    }

    data[(SHA_LBLOCK << 3) - 1]  = (Nl >>  0) & 0xff;
    data[(SHA_LBLOCK << 3) - 2]  = (Nl >>  8) & 0xff;
    data[(SHA_LBLOCK << 3) - 3]  = (Nl >> 16) & 0xff;
    data[(SHA_LBLOCK << 3) - 4]  = (Nl >> 24) & 0xff;
    data[(SHA_LBLOCK << 3) - 5]  = (Nl >> 32) & 0xff;
    data[(SHA_LBLOCK << 3) - 6]  = (Nl >> 40) & 0xff;
    data[(SHA_LBLOCK << 3) - 7]  = (Nl >> 48) & 0xff;
    data[(SHA_LBLOCK << 3) - 8]  = (Nl >> 56) & 0xff;

    data[(SHA_LBLOCK << 3) - 9]  = (Nh >>  0) & 0xff;
    data[(SHA_LBLOCK << 3) - 10] = (Nh >>  8) & 0xff;
    data[(SHA_LBLOCK << 3) - 11] = (Nh >> 16) & 0xff;
    data[(SHA_LBLOCK << 3) - 12] = (Nh >> 24) & 0xff;
    data[(SHA_LBLOCK << 3) - 13] = (Nh >> 32) & 0xff;
    data[(SHA_LBLOCK << 3) - 14] = (Nh >> 40) & 0xff;
    data[(SHA_LBLOCK << 3) - 15] = (Nh >> 48) & 0xff;
    data[(SHA_LBLOCK << 3) - 16] = (Nh >> 56) & 0xff;

    sha512_block_data_order(h, 1, data);

    for (unsigned k = 0; k < out_bytes; k += 8)
    {
        /* Considering an output of 64 bytes. */
        #pragma HLS loop_tripcount min=8 max=8

        out[k + 0] = (h[k >> 3] >> 56) & 0xff;
        out[k + 1] = (h[k >> 3] >> 48) & 0xff;
        out[k + 2] = (h[k >> 3] >> 40) & 0xff;
        out[k + 3] = (h[k >> 3] >> 32) & 0xff;
        out[k + 4] = (h[k >> 3] >> 24) & 0xff;
        out[k + 5] = (h[k >> 3] >> 16) & 0xff;
        out[k + 6] = (h[k >> 3] >>  8) & 0xff;
        out[k + 7] = (h[k >> 3] >>  0) & 0xff;
    }
}

#endif /* __SHA2_512_H__ */
