#ifndef __STRING_MNTR_H__
#define __STRING_MNTR_H__

template<typename T>
void memcpy_mntr(T *dst, T *src, size_t num) {
    for (size_t i = 0; i < num; i++)
        dst[i] = src[i];
}

template<typename T>
void memset_mntr(T *ptr, int value, size_t num) {
    for (size_t i = 0; i < num; i++)
        ptr[i] = value;
}

#endif
