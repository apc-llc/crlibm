# TODO:
# 1) triple and data layout

.SUFFIXES: .cu .CUF

CC = gcc
CLANG = /opt/llvm-3.0/bin/clang #-march=nvptx
NVCC = nvcc
GPUARCH ?= 30
BITS = 32
LDBITS =
ifeq ($(BITS), 32)
	LDBITS := -melf_i386
endif
FMAD = 0

CICC = /opt/cuda/nvvm/bin/cicc
LIBDEVICE := -nvvmir-library $(shell dirname $(shell which $(CICC)))/../libdevice/libdevice.compute_$(GPUARCH).10.bc
CICC += -arch compute_$(GPUARCH) -m$(BITS) -ftz=0 -prec_div=1 -prec_sqrt=1 -fmad=$(FMAD) $(LIBDEVICE) --device-c

DEFS = -DLINUX_INLINE -DHAVE_CONFIG_H -I.
CFLAGS = -g -O2 -m$(BITS)
FCF ?= -g -O2 -m$(BITS)

OBJS = addition_scs.o multiplication_scs.o \
     double2scs.o scs2double.o zero_scs.o \
     trigo_fast.o tan.o sine.o cosine.o \
     exp.o logsix.o exp_fast.o log_fast.o \
     atan.o atan_fast.o division_scs.o \
     csh_fast.o log10.o rem_pio2.o \
     dtoa_c.o dtoaf.o round_near.o disable_xp.o enable_xp.o \
     crlibm.cpu.o

ifeq ($(FC),pgf90)
OBJS += crlibm.gpu.o exit.o
FCF += -DCUDAFOR
else
FCF += -x f95 -cpp
endif

all: crlibm.a

crlibm.a: $(OBJS)
	ar -rv crlibm.a $(OBJS)

AM1_CFLAGS = -fPIC -std=c99 -Wall -Wshadow -Wpointer-arith  -Wcast-align -Wconversion -Waggregate-return -Wstrict-prototypes -Wnested-externs -Wlong-long -Winline -pedantic -fno-strict-aliasing
COMPILE1 = $(CC) $(DEFS) $(AM1_CFLAGS) $(CFLAGS)
CLANG1 = $(CLANG) $(DEFS) $(AM1_CFLAGS) $(filter-out -g, $(CFLAGS)) -D__CUDACC__ -D"fprintf(file, ...)"=""

%.i:
	touch $@

ifeq ($(FC),pgf90)
csh_fast.o: csh_fast.c crlibm.h crlibm_private.h scs.h \
        scs_config.h scs_private.h crlibm_config.h \
        csh_fast.h csh_fast.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
rem_pio2.o: rem_pio2.c crlibm.h crlibm_private.h scs.h \
        scs_config.h scs_private.h crlibm_config.h \
        coefpi2.h rem_pio2.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
trigo_fast.o: trigo_fast.c crlibm.h crlibm_private.h scs.h \
        scs_config.h scs_private.h crlibm_config.h \
        trigo_fast.h trigo_fast.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
tan.o: tan.c crlibm.h crlibm_private.h scs.h \
        scs_config.h scs_private.h crlibm_config.h \
        tan.h tan.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
sine.o: sine.c crlibm.h crlibm_private.h scs.h \
        scs_config.h scs_private.h crlibm_config.h \
        sine.h sine.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
cosine.o: cosine.c crlibm.h crlibm_private.h scs.h \
        scs_config.h scs_private.h crlibm_config.h \
        cosine.h cosine.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
exp.o: exp.c crlibm.h crlibm_private.h scs.h \
	scs_config.h scs_private.h crlibm_config.h \
	exp.h exp.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
exp_fast.o: exp_fast.c crlibm.h crlibm_private.h scs.h \
	scs_config.h scs_private.h crlibm_config.h \
	exp_fast.h exp_fast.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
logsix.o: logsix.c logsix.h crlibm.h crlibm_private.h scs.h \
	scs_config.h scs_private.h crlibm_config.h \
        logsix.h logsix.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
log_fast.o: log_fast.c crlibm.h crlibm_private.h scs.h \
	scs_config.h scs_private.h crlibm_config.h \
        log_fast.h log_fast.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
log10.o: log10.c log10.h crlibm.h crlibm_private.h scs.h \
	scs_config.h scs_private.h crlibm_config.h \
        log10.h log10.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
atan.o: atan.c atan.h crlibm.h crlibm_private.h scs.h \
        scs_config.h scs_private.h crlibm_config.h \
        atan_fast.h atan.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
atan_fast.o: atan_fast.c crlibm.h crlibm_private.h scs.h \
        scs_config.h scs_private.h crlibm_config.h \
        atan_fast.h atan_fast.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
disable_xp.o: disable_xp.c disable_xp.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
enable_xp.o: enable_xp.c enable_xp.i
	$(CLANG1) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE1) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
round_near.o: round_near.c round_near.i
	$(CLANG) -m32 -std=c99 -W -Wall -pedantic -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -O0 -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -O0 -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(CC) -m32 -std=c99 -W -Wall -pedantic -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
dtoa_c.o: dtoa_c.c dtoa_c.i
	$(CLANG) -m32 -std=c99 -W -Wall -pedantic -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -O0 -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && sed -i s/\\.str/str/ $(basename $<).ptx && sed -i s/pow5mult\.p05/pow5mult_p05/ $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -O0 -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(CC) -m32 -std=c99 -W -Wall -pedantic -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
dtoaf.o: dtoaf.c dtoaf.i
	$(CLANG) -m32 -std=c99 -W -Wall -pedantic -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -O0 -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(CC) -m32 -std=c99 -W -Wall -pedantic -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

AM2_CFLAGS = -Wall -Wshadow -Wpointer-arith -Wcast-align -Wconversion -Waggregate-return -Wstrict-prototypes -Wnested-externs -Wlong-long -Winline 
COMPILE2 = $(CC) $(DEFS) $(AM2_CFLAGS) $(CFLAGS)
CLANG2 = $(CLANG) $(DEFS) $(AM2_CFLAGS) $(filter-out -g, $(CFLAGS)) -D__CUDACC__ -D"fprintf(file, ...)"=""

ifeq ($(FC),pgf90)
addition_scs.o: addition_scs.c scs.h scs_config.h scs_private.h addition_scs.i
	$(CLANG2) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE2) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
double2scs.o: double2scs.c scs.h scs_config.h scs_private.h double2scs.i
	$(CLANG2) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE2) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
multiplication_scs.o: multiplication_scs.c scs.h scs_config.h \
	scs_private.h multiplication_scs.i
	$(CLANG2) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE2) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
division_scs.o: division_scs.c scs.h scs_config.h \
	scs_private.h division_scs.i
	$(CLANG2) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE2) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
scs2double.o: scs2double.c scs.h scs_config.h scs_private.h scs2double.i
	$(CLANG2) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && touch $(basename $<).def.cu && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE2) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
zero_scs.o: zero_scs.c scs.h scs_config.h scs_private.h zero_scs.i
	$(CLANG2) -emit-llvm -c $< -o $(basename $<).bc && $(CICC) -nvvmir-library $(basename $<).bc $(basename $<).i -o $(basename $<).ptx && $(NVCC) -m$(BITS) $(basename $<).def.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && touch $(basename $<).def.module_id && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).def.module_id` $@.def.o && $(NVCC) -m$(BITS) $(basename $<).ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).def.module_id` -o $@.ptx.o && $(COMPILE2) -c $< -o $<.cpu.o && ld $(LDBITS) -r $<.cpu.o $@.ptx.o $@.def.o -o $@
else
endif

ifeq ($(FC),pgf90)
exit.o: exit.cu
	$(NVCC) -m$(BITS) -O3 --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -c $< -o $<.o && objcopy --redefine-sym exit=exit_defined_by_stupid_cuda $<.o $@
endif

CRLIBM_MODULES := crlibm=crlibm
CRLIBM_MODULES := $(addprefix -D, $(CRLIBM_MODULES))
CRLIBM_MODULES_GPU := $(addsuffix _gpu, $(CRLIBM_MODULES))
CRLIBM_MODULES_CPU :=

ifeq ($(FC),pgf90)
crlibm.gpu.o: crlibm.CUF
	rm -rf $(basename $<).n001.h $(basename $<).n001.gpu $(basename $<).n001.ptx && $(FC) -c $(FCF) $< $(CRLIBM_MODULES_GPU) -o $<.o -DGPU && (test -s $(basename $<).n001.ptx || { echo ".version 4.0\n.target sm_$(GPUARCH)\n.address_size $(BITS)\n" > $(basename $<).n001.ptx; }) && sed -i s/staticinit/$(shell echo \"$<_$(shell date)\" | base64  | sed s/=/_/g)/g $(basename $<).n001.ptx && sed -i s/__static_2/$(shell echo \"$<_$(shell date)\" | base64  | sed s/=/_/g)_2/g $(basename $<).n001.ptx && sed -i -r "s/_([a-zA-Z0-9]+)_gpu_16/__MOD_\1/g" $(basename $<).n001.ptx && touch $(basename $<).n001.h && ln -sf $(basename $<).n001.h $(basename $<).n002.cu && $(NVCC) -m$(BITS) $(basename $<).n002.cu --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -o $@.def.o -keep && objcopy --weaken-symbol=__fatbinwrap`cat $(basename $<).n002.module_id` $@.def.o && touch $(basename $<).n001.module_id && $(NVCC) -m$(BITS) $(basename $<).n001.ptx --device-c -arch=compute_$(GPUARCH) -code=sm_$(GPUARCH),compute_$(GPUARCH) -D__NV_MODULE_ID=`cat $(basename $<).n002.module_id` -o $@.ptx.o && ld $(LDBITS) -r $@.ptx.o $@.def.o -o $@
endif

crlibm.cpu.o: crlibm.CUF
	$(FC) -c $(FCF) $< $(CRLIBM_MODULES_CPU) -o $@

clean:
	rm -f $(OBJS) crlibm.a *.o *.i *.ptx *.bc *.mod *.n001.h *.n001.gpu *.n001.ptx *.n002.ptx *.n002.cu *.cpp1.ii *.cpp2.i *.cpp3.i *.cpp4.ii *.cu.cpp.ii *.cudafe1.cpp *.cudafe1.gpu *.cudafe2.gpu *.fatbin *.module_id *.hash *.sm_*.cubin

