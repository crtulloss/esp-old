/* -*-Mode: C;-*- */

#include <stdio.h>
#include <stdlib.h>

#include "fft-1d.h"

#include "calc_fmcw_dist.h"

#ifdef HW_FFT
#include "contig.h"
#include "fixed_point.h"
#include "mini-era.h"

//#define FFT_DEVNAME  "/dev/fft.0"

extern int32_t fftHW_len;
extern int32_t fftHW_log_len;

extern int fftHW_fd;
extern contig_handle_t fftHW_mem;
extern int64_t* fftHW_lmem;

extern struct fftHW_access fftHW_desc;

unsigned int fft_rev(unsigned int v)
{
        unsigned int r = v;
        int s = sizeof(v) * CHAR_BIT - 1;

        for (v >>= 1; v; v >>= 1) {
                r <<= 1;
                r |= v & 1;
                s--;
        }
        r <<= s;
        return r;
}

void fft_bit_reverse(float *w, unsigned int n, unsigned int bits)
{
        unsigned int i, s, shift;

        s = sizeof(i) * CHAR_BIT - 1;
        shift = s - bits + 1;

        for (i = 0; i < n; i++) {
                unsigned int r;
                float t_real, t_imag;

                r = fft_rev(i);
                r >>= shift;

                if (i < r) {
                        t_real = w[2 * i];
                        t_imag = w[2 * i + 1];
                        w[2 * i] = w[2 * r];
                        w[2 * i + 1] = w[2 * r + 1];
                        w[2 * r] = t_real;
                        w[2 * r + 1] = t_imag;
                }
        }
}


static void fft_in_hw(/*unsigned char *inMemory,*/ int *fd, /*contig_handle_t *mem, size_t size, size_t out_size,*/ struct fftHW_access *desc)
{
  //contig_copy_to(*mem, 0, inMemory, size);

  if (ioctl(*fd, FFTHW_IOC_ACCESS, *desc)) {
    perror("IOCTL:");
    exit(EXIT_FAILURE);
  }

  //contig_copy_from(inMemory, *mem, 0, out_size);
}
#endif

float calculate_peak_dist_from_fmcw(float* data)
{
#ifdef HW_FFT
  // preprocess with bitreverse (fast in software anyway)
  fft_bit_reverse(data, fftHW_len, fftHW_log_len);
  // convert input to fixed point
  for (int j = 0; j < 2 * fftHW_len; j++) {
    fftHW_lmem[j] = double_to_fixed64((double) data[j], 42);
  }
  fft_in_hw(&fftHW_fd, &fftHW_desc);
  for (int j = 0; j < 2 * fftHW_len; j++) {
    data[j] = (float)fixed64_to_double(fftHW_lmem[j], 42);
  }
#else
  fft (data, RADAR_N, RADAR_LOGN, -1);
#endif
  float max_psd = 0;
  unsigned int max_index = 0;
  unsigned int i;
  float temp;
  for (i=0; i < RADAR_N; i++) {
    temp = (pow(data[2*i],2) + pow(data[2*i+1],2))/100.0;
    if (temp > max_psd) {
      max_psd = temp;
      max_index = i;
    }
  }
  float distance = ((float)(max_index*((float)RADAR_fs)/((float)(RADAR_N))))*0.5*RADAR_c/((float)(RADAR_alpha));
  //printf("Max distance is %.3f\nMax PSD is %4E\nMax index is %d\n", distance, max_psd, max_index);
  if (max_psd > 1e-10*pow(8192,2)) {
    return distance;
  } else {
    return INFINITY;
  }
}

