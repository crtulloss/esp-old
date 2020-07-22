#ifndef __UTILS_HPP__
#define __UTILS_HPP__

#ifdef __SYNTHESIS__

#define REPORT_INFO(...)
#define REPORT_ERROR(...)
#define REPORT_TIME(time, ...)

#else

#include <systemc.h>
#include <stdio.h>

#define VON 1
#define VOFF 0

#define REPORT_INFO(verbosity, ...) \
  if (verbosity == VON) \
  { fprintf(stderr, "Info: %s.%s(): ", sc_object::basename(), __func__); \
    fprintf(stderr, __VA_ARGS__); \
    fprintf(stderr, "\n"); }

#define REPORT_ERROR(verbosity, ...) \
  if (verbosity == VON) \
  { fprintf(stderr, "Error: %s.%s(): ", sc_object::basename(), __func__); \
    fprintf(stderr, __VA_ARGS__); \
    fprintf(stderr, "\n"); }

#define REPORT_TIME(verbosity, time, ...) \
  if (verbosity == VON) \
  { double ns = time.to_default_time_units(); \
    fprintf(stderr, "Info: @%.1fns: ", ns); \
    fprintf(stderr, "%s.%s(): ", sc_object::basename(), __func__); \
    fprintf(stderr, __VA_ARGS__); \
    fprintf(stderr, "\n"); }

#endif

#define TO_UINT64(x) x.to_uint64()
#define TO_INT64(x) x.to_int64()
#define TO_UINT32(x) x.to_uint()
#define TO_INT32(x) x.to_int()

#endif /* __UTILS_HPP__ */
