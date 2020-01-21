
TARGET = it-fcmainF32.exe
CFLAGS = -I../../include -std=c99 -DUSE_ESP_INTERFACE -DINT_TIME -DHW_FFT -DUSE_FFT_FX=32 -DBYPASS_KERAS_CV_CODE
VTARGET = it-vfcmainF32.exe
VCFLAGS = $(CFLAGS) -DVERBOSE

SRC_S = $(wildcard *.c)
OBJ_S = $(SRC_S:.c=.o)


compile: $(TARGET)


include ../../common.mk


%.o: %.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c $< -o $@

it-fcmainF32.exe: $(OBJ_S)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../libesp
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

it-vfcmainF32.exe: $(OBJ_S)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../libesp
	$(CROSS_COMPILE)$(CC) $(VCFLAGS) $^ -o $@ $(LDFLAGS)

.PHONY: compile
