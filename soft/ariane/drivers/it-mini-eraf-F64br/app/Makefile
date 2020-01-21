
TARGET = it-fcmainF64br.exe
CFLAGS = -I../../include -std=c99 -DUSE_ESP_INTERFACE -DINT_TIME -DHW_FFT -DHW_FFT_BITREV -DUSE_FFT_FX=64 -DBYPASS_KERAS_CV_CODE
#TARGET = it-vfcmainF64br.exe
#CFLAGS = -I../../include -std=c99 -DUSE_ESP_INTERFACE -DINT_TIME -DHW_FFT -DHW_FFT_BITREV -DUSE_FFT_FX=64 -DBYPASS_KERAS_CV_CODE -DVERBOSE

SRC_S = $(wildcard *.c)
OBJ_S = $(SRC_S:.c=.o)


compile: $(TARGET)


include ../../common.mk


%.o: %.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c $< -o $@

it-fcmainF64br.exe: $(OBJ_S)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../libesp
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

it-vfcmainF64br.exe: $(OBJ_S)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../libesp
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

.PHONY: compile
