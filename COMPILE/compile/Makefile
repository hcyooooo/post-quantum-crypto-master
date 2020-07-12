########################
### General settings ###
########################
PREFIX?=/opt/risqv/bin/riscv32-unknown-elf-
CC=$(PREFIX)gcc
AS=$(CC) -x assembler-with-cpp
OBJCOPY=$(PREFIX)objcopy
OBJSIZE=$(PREFIX)size
PULPINO_REPO=$(shell realpath "utils")
SRECTOSLM=python "$(PULPINO_REPO)/s19toslm.py"

ARCHFLAGS=-march=rv32imfcxpulpv3 -mabi=ilp32
# machine flags: -msmall-data-limit is RISCV-specific, but can't be passed to LD
CFLAGS+=$(ARCHFLAGS) -msmall-data-limit=8
# diagnostics flags
CFLAGS+=-fmessage-length=0
# C options
CFLAGS+=-std=gnu11 -fsigned-char
CFLAGS+=-I"../lib"
CFLAGS+=-I"../src/mupq/common"
# optimization options
CFLAGS+=-fdata-sections -ffunction-sections -O3
# debug options
CFLAGS+=-g0

LDFLAGS+=-T"link.riscv.ld" -nostartfiles -Wl,--gc-sections
LDFLAGS+=-Wl,-Map,"project.map"

########################
###   Library Files  ###
########################
LIBSRCS:=$(wildcard ../lib/*.c)
LIBSRCS_ASM=$(wildcard ../lib/*.S)


########################
###     Includes     ###
########################
INCDIR = -I../src/RISCV_optimized_code


########################
###     Prefixes     ###
########################
COMMONPREFIX_CLEAN = ../src/PQClean/common
COMMONPREFIX_MUPQ = ../src/mupq/common
RISCVOPTPREFIX = ../src/RISCV_optimized_code
NEWHOPE512PREFIX = ../src/PQClean/crypto_kem/newhope512cca/clean
NEWHOPE1024PREFIX = ../src/PQClean/crypto_kem/newhope1024cca/clean
KYBER512PREFIX = ../src/PQClean/crypto_kem/kyber512/clean
KYBER768PREFIX = ../src/PQClean/crypto_kem/kyber768/clean
KYBER1024PREFIX = ../src/PQClean/crypto_kem/kyber1024/clean
LIGHTSABERPREFIX = ../src/PQClean/crypto_kem/lightsaber/clean
SABERPREFIX = ../src/PQClean/crypto_kem/saber/clean
FIRESABERPREFIX = ../src/PQClean/crypto_kem/firesaber/clean


########################
###     NEWHOPE      ###
########################
### NEWHOPE512 ###
NEWHOPE512SRCS_C = $(NEWHOPE512PREFIX)/cpapke.c \
    $(NEWHOPE512PREFIX)/kem.c \
    $(NEWHOPE512PREFIX)/ntt.c \
    $(NEWHOPE512PREFIX)/poly.c \
    $(NEWHOPE512PREFIX)/precomp.c \
    $(NEWHOPE512PREFIX)/reduce.c \
    $(NEWHOPE512PREFIX)/verify.c \
    $(COMMONPREFIX_MUPQ)/fips202.c \
    $(COMMONPREFIX_MUPQ)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/newhope512cca/crypto_kem_bench.c

### NEWHOPE512 HW ###
NEWHOPE512HWSRCS_C = $(RISCVOPTPREFIX)/newhope512cca/cpapke.c \
    $(NEWHOPE512PREFIX)/kem.c \
    $(RISCVOPTPREFIX)/newhope512cca/ntt_unrolled.c \
    $(RISCVOPTPREFIX)/newhope512cca/poly.c \
    $(NEWHOPE512PREFIX)/verify.c \
    $(RISCVOPTPREFIX)/fips202.c \
    $(RISCVOPTPREFIX)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/newhope512cca/crypto_kem_bench.c

NEWHOPE512HWSRCS_ASM = $(RISCVOPTPREFIX)/newhope512cca/PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sample.S

### NEWHOPE1024 ###
NEWHOPE1024SRCS_C = $(NEWHOPE1024PREFIX)/cpapke.c \
    $(NEWHOPE1024PREFIX)/kem.c \
    $(NEWHOPE1024PREFIX)/ntt.c \
    $(NEWHOPE1024PREFIX)/poly.c \
    $(NEWHOPE1024PREFIX)/precomp.c \
    $(NEWHOPE1024PREFIX)/reduce.c \
    $(NEWHOPE1024PREFIX)/verify.c \
    $(COMMONPREFIX_MUPQ)/fips202.c \
    $(COMMONPREFIX_MUPQ)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/newhope1024cca/crypto_kem_bench.c

### NEWHOPE1024 HW ###
NEWHOPE1024HWSRCS_C = $(RISCVOPTPREFIX)/newhope1024cca/cpapke.c \
    $(NEWHOPE1024PREFIX)/kem.c \
    $(RISCVOPTPREFIX)/newhope1024cca/ntt_unrolled.c \
    $(RISCVOPTPREFIX)/newhope1024cca/poly.c \
    $(NEWHOPE1024PREFIX)/verify.c \
    $(RISCVOPTPREFIX)/fips202.c \
    $(RISCVOPTPREFIX)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/newhope1024cca/crypto_kem_bench.c

NEWHOPE1024HWSRCS_ASM = $(RISCVOPTPREFIX)/newhope1024cca/PQCLEAN_NEWHOPE1024CCA_CLEAN_poly_sample.S


########################
###      KYBER       ###
########################
### KYBER512 ###
KYBER512SRCS_C = $(KYBER512PREFIX)/cbd.c \
    $(KYBER512PREFIX)/indcpa.c \
    $(KYBER512PREFIX)/kem.c \
    $(KYBER512PREFIX)/ntt.c \
    $(KYBER512PREFIX)/poly.c \
    $(KYBER512PREFIX)/polyvec.c \
    $(KYBER512PREFIX)/reduce.c \
    $(KYBER512PREFIX)/symmetric-fips202.c \
    $(KYBER512PREFIX)/verify.c \
    $(COMMONPREFIX_MUPQ)/fips202.c \
    $(COMMONPREFIX_MUPQ)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/kyber512/crypto_kem_bench.c \

### KYBER512 HW ###
KYBER512HWSRCS_C = $(RISCVOPTPREFIX)/kyber512/cbd.c \
    $(RISCVOPTPREFIX)/kyber512/indcpa.c \
    $(KYBER512PREFIX)/kem.c \
    $(RISCVOPTPREFIX)/kyber512/ntt.c \
    $(RISCVOPTPREFIX)/kyber512/poly.c \
    $(RISCVOPTPREFIX)/kyber512/polyvec.c \
    $(KYBER512PREFIX)/reduce.c \
    $(RISCVOPTPREFIX)/kyber512/symmetric-fips202.c \
    $(KYBER512PREFIX)/verify.c \
    $(RISCVOPTPREFIX)/fips202.c \
    $(RISCVOPTPREFIX)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/kyber512/crypto_kem_bench.c \

KYBER512HWSRCS_ASM = $(RISCVOPTPREFIX)/kyber512/fastntt.S \
    $(RISCVOPTPREFIX)/kyber512/fastinvntt.S \
    $(RISCVOPTPREFIX)/kyber512/poly_basemul.S \

### KYBER768 ###
KYBER768SRCS_C = $(KYBER768PREFIX)/cbd.c \
    $(KYBER768PREFIX)/indcpa.c \
    $(KYBER768PREFIX)/kem.c \
    $(KYBER768PREFIX)/ntt.c \
    $(KYBER768PREFIX)/poly.c \
    $(KYBER768PREFIX)/polyvec.c \
    $(KYBER768PREFIX)/reduce.c \
    $(KYBER768PREFIX)/symmetric-fips202.c \
    $(KYBER768PREFIX)/verify.c \
    $(COMMONPREFIX_MUPQ)/fips202.c \
    $(COMMONPREFIX_MUPQ)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/kyber768/crypto_kem_bench.c \

### KYBER768 HW ###
KYBER768HWSRCS_C = $(RISCVOPTPREFIX)/kyber768/cbd.c \
    $(RISCVOPTPREFIX)/kyber768/indcpa.c \
    $(KYBER768PREFIX)/kem.c \
    $(RISCVOPTPREFIX)/kyber768/ntt.c \
    $(RISCVOPTPREFIX)/kyber768/poly.c \
    $(RISCVOPTPREFIX)/kyber768/polyvec.c \
    $(KYBER768PREFIX)/reduce.c \
    $(RISCVOPTPREFIX)/kyber768/symmetric-fips202.c \
    $(KYBER768PREFIX)/verify.c \
    $(RISCVOPTPREFIX)/fips202.c \
    $(RISCVOPTPREFIX)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/kyber768/crypto_kem_bench.c \

KYBER768HWSRCS_ASM = $(RISCVOPTPREFIX)/kyber768/fastntt.S \
    $(RISCVOPTPREFIX)/kyber768/fastinvntt.S \
    $(RISCVOPTPREFIX)/kyber768/poly_basemul.S \


### KYBER1024 ###
KYBER1024SRCS_C = $(KYBER1024PREFIX)/cbd.c \
    $(KYBER1024PREFIX)/indcpa.c \
    $(KYBER1024PREFIX)/kem.c \
    $(KYBER1024PREFIX)/ntt.c \
    $(KYBER1024PREFIX)/poly.c \
    $(KYBER1024PREFIX)/polyvec.c \
    $(KYBER1024PREFIX)/reduce.c \
    $(KYBER1024PREFIX)/symmetric-fips202.c \
    $(KYBER1024PREFIX)/verify.c \
    $(COMMONPREFIX_MUPQ)/fips202.c \
    $(COMMONPREFIX_MUPQ)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/kyber1024/crypto_kem_bench.c \

### KYBER1024 HW ###
KYBER1024HWSRCS_C = $(RISCVOPTPREFIX)/kyber1024/cbd.c \
    $(RISCVOPTPREFIX)/kyber1024/indcpa.c \
    $(KYBER1024PREFIX)/kem.c \
    $(RISCVOPTPREFIX)/kyber1024/ntt.c \
    $(RISCVOPTPREFIX)/kyber1024/poly.c \
    $(RISCVOPTPREFIX)/kyber1024/polyvec.c \
    $(KYBER1024PREFIX)/reduce.c \
    $(RISCVOPTPREFIX)/kyber1024/symmetric-fips202.c \
    $(KYBER1024PREFIX)/verify.c \
    $(RISCVOPTPREFIX)/fips202.c \
    $(RISCVOPTPREFIX)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/kyber1024/crypto_kem_bench.c \

KYBER1024HWSRCS_ASM = $(RISCVOPTPREFIX)/kyber1024/fastntt.S \
    $(RISCVOPTPREFIX)/kyber1024/fastinvntt.S \
    $(RISCVOPTPREFIX)/kyber512/poly_basemul.S \


########################
###      SABER       ###
########################
### LIGHTSABER ###
LIGHTSABERSRCS_C = $(LIGHTSABERPREFIX)/kem.c \
    $(LIGHTSABERPREFIX)/pack_unpack.c \
    $(LIGHTSABERPREFIX)/poly.c \
    $(LIGHTSABERPREFIX)/verify.c \
    $(LIGHTSABERPREFIX)/cbd.c \
    $(LIGHTSABERPREFIX)/SABER_indcpa.c \
    $(LIGHTSABERPREFIX)/poly_mul.c \
    $(COMMONPREFIX_MUPQ)/fips202.c \
    $(COMMONPREFIX_MUPQ)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/lightsaber/crypto_kem_bench.c \

### LIGHTSABER HW ###
LIGHTSABERHWSRCS_C = $(LIGHTSABERPREFIX)/kem.c \
    $(LIGHTSABERPREFIX)/pack_unpack.c \
    $(RISCVOPTPREFIX)/lightsaber/poly.c \
    $(LIGHTSABERPREFIX)/verify.c \
    $(RISCVOPTPREFIX)/lightsaber/cbd.c \
    $(RISCVOPTPREFIX)/lightsaber/SABER_indcpa.c \
    $(RISCVOPTPREFIX)/lightsaber/poly_mul.c \
    $(RISCVOPTPREFIX)/lightsaber/shake128_saber.c \
    $(RISCVOPTPREFIX)/fips202.c \
    $(RISCVOPTPREFIX)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/lightsaber/crypto_kem_bench.c \

### SABER ###
SABERSRCS_C = $(SABERPREFIX)/kem.c \
    $(SABERPREFIX)/pack_unpack.c \
    $(SABERPREFIX)/poly.c \
    $(SABERPREFIX)/verify.c \
    $(SABERPREFIX)/cbd.c \
    $(SABERPREFIX)/SABER_indcpa.c \
    $(SABERPREFIX)/poly_mul.c \
    $(COMMONPREFIX_MUPQ)/fips202.c \
    $(COMMONPREFIX_MUPQ)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/saber/crypto_kem_bench.c \

### SABER HW ###
SABERHWSRCS_C = $(SABERPREFIX)/kem.c \
    $(SABERPREFIX)/pack_unpack.c \
    $(RISCVOPTPREFIX)/saber/poly.c \
    $(SABERPREFIX)/verify.c \
    $(RISCVOPTPREFIX)/saber/cbd.c \
    $(RISCVOPTPREFIX)/saber/SABER_indcpa.c \
    $(RISCVOPTPREFIX)/saber/poly_mul.c \
    $(RISCVOPTPREFIX)/saber/shake128_saber.c \
    $(RISCVOPTPREFIX)/fips202.c \
    $(RISCVOPTPREFIX)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/saber/crypto_kem_bench.c \

### FIRESABER ###
FIRESABERSRCS_C = $(FIRESABERPREFIX)/kem.c \
    $(FIRESABERPREFIX)/pack_unpack.c \
    $(FIRESABERPREFIX)/poly.c \
    $(FIRESABERPREFIX)/verify.c \
    $(FIRESABERPREFIX)/cbd.c \
    $(FIRESABERPREFIX)/SABER_indcpa.c \
    $(FIRESABERPREFIX)/poly_mul.c \
    $(COMMONPREFIX_MUPQ)/fips202.c \
    $(COMMONPREFIX_MUPQ)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/firesaber/crypto_kem_bench.c \


### FIRESABERHW ###
FIRESABERHWSRCS_C = $(FIRESABERPREFIX)/kem.c \
    $(FIRESABERPREFIX)/pack_unpack.c \
    $(RISCVOPTPREFIX)/firesaber/poly.c \
    $(FIRESABERPREFIX)/verify.c \
    $(RISCVOPTPREFIX)/firesaber/cbd.c \
    $(RISCVOPTPREFIX)/firesaber/SABER_indcpa.c \
    $(RISCVOPTPREFIX)/firesaber/poly_mul.c \
    $(RISCVOPTPREFIX)/firesaber/shake128_saber.c \
    $(RISCVOPTPREFIX)/fips202.c \
    $(RISCVOPTPREFIX)/keccakf1600.c \
    $(RISCVOPTPREFIX)/notrandombytes.c \
    ../src/bench_targets/firesaber/crypto_kem_bench.c \



########################
###   Make Targets   ###
########################
.PHONY: all clean

all: newhope512_bench newhope512hw_bench newhope1024_bench newhope1024hw_bench kyber512_bench kyber512hw_bench kyber768_bench kyber768hw_bench kyber1024_bench kyber1024hw_bench lightsaber_bench lightsaberhw_bench saber_bench saberhw_bench firesaber_bench firesaberhw_bench


########################
###     NEWHOPE      ###
########################
######## NEWHOPE512 TARGET ########
newhope512_bench: INCDIR += -I../src/PQClean/crypto_kem/newhope512cca/clean
newhope512_bench: newhope512_bench.elf slm/newhope512_bench.txt

newhope512_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(NEWHOPE512SRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/newhope512_bench.txt: newhope512_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/newhope512cca


######## NEWHOPE512HW TARGET ########
newhope512hw_bench: INCDIR += -I../src/RISCV_optimized_code/newhope512cca
newhope512hw_bench: newhope512hw_bench.elf slm/newhope512hw_bench.txt

newhope512hw_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(NEWHOPE512HWSRCS_C:.c=.o) $(NEWHOPE512HWSRCS_ASM:.S=_asm.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/newhope512hw_bench.txt: newhope512hw_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/newhope512cca_ext


######## NEWHOPE1024 TARGET ########
newhope1024_bench: INCDIR += -I../src/PQClean/crypto_kem/newhope1024cca/clean
newhope1024_bench: newhope1024_bench.elf slm/newhope1024_bench.txt

newhope1024_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(NEWHOPE1024SRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/newhope1024_bench.txt: newhope1024_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/newhope1024cca


######## NEWHOPE1024HW TARGET ########
newhope1024hw_bench: INCDIR += -I../src/RISCV_optimized_code/newhope1024cca
newhope1024hw_bench: newhope1024hw_bench.elf slm/newhope1024hw_bench.txt

newhope1024hw_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(NEWHOPE1024HWSRCS_C:.c=.o) $(NEWHOPE1024HWSRCS_ASM:.S=_asm.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/newhope1024hw_bench.txt: newhope1024hw_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/newhope1024cca_ext


########################
###      KYBER       ###
########################
######## KYBER512 TARGET ########
kyber512_bench: INCDIR += -I../src/PQClean/crypto_kem/kyber512/clean
kyber512_bench: kyber512_bench.elf slm/kyber512_bench.txt

kyber512_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(KYBER512SRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/kyber512_bench.txt: kyber512_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/kyber512


######## KYBER512HW TARGET ########
kyber512hw_bench: INCDIR += -I../src/PQClean/crypto_kem/kyber512/clean
kyber512hw_bench: kyber512hw_bench.elf slm/kyber512hw_bench.txt

kyber512hw_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(KYBER512HWSRCS_C:.c=.o) $(KYBER512HWSRCS_ASM:.S=_asm.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/kyber512hw_bench.txt: kyber512hw_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/kyber512_ext


######## KYBER768 TARGET ########
kyber768_bench: INCDIR += -I../src/PQClean/crypto_kem/kyber768/clean
kyber768_bench: kyber768_bench.elf slm/kyber768_bench.txt

kyber768_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(KYBER768SRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/kyber768_bench.txt: kyber768_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/kyber768


######## KYBER768HW TARGET ########
kyber768hw_bench: INCDIR += -I../src/PQClean/crypto_kem/kyber768/clean
kyber768hw_bench: kyber768hw_bench.elf slm/kyber768hw_bench.txt

kyber768hw_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(KYBER768HWSRCS_C:.c=.o) $(KYBER768HWSRCS_ASM:.S=_asm.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/kyber768hw_bench.txt: kyber768hw_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/kyber768_ext


######## KYBER1024 TARGET ########
kyber1024_bench: INCDIR += -I../src/PQClean/crypto_kem/kyber1024/clean
kyber1024_bench: kyber1024_bench.elf slm/kyber1024_bench.txt

kyber1024_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(KYBER1024SRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/kyber1024_bench.txt: kyber1024_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/kyber1024


######## KYBER1024HW TARGET ########
kyber1024hw_bench: INCDIR += -I../src/PQClean/crypto_kem/kyber1024/clean
kyber1024hw_bench: kyber1024hw_bench.elf slm/kyber1024hw_bench.txt

kyber1024hw_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(KYBER1024HWSRCS_C:.c=.o) $(KYBER1024HWSRCS_ASM:.S=_asm.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/kyber1024hw_bench.txt: kyber1024hw_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/kyber1024_ext


# -------------------- KYBER GENERATE ASM ---------------------
kyber_asm: $(KYBERCLEANSRCS:.c=.S)


########################
###      SABER       ###
########################
######## LIGHTSABER TARGET ########
lightsaber_bench: INCDIR += -I../src/PQClean/crypto_kem/lightsaber/clean
lightsaber_bench: lightsaber_bench.elf slm/lightsaber_bench.txt

lightsaber_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(LIGHTSABERSRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/lightsaber_bench.txt: lightsaber_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/lightsaber


######## LIGHTSABERHW TARGET ########
lightsaberhw_bench: INCDIR += -I../src/PQClean/crypto_kem/lightsaber/clean
lightsaberhw_bench: INCDIR += -I$(RISCVOPTPREFIX)/lightsaber
lightsaberhw_bench: lightsaberhw_bench.elf slm/lightsaberhw_bench.txt

lightsaberhw_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(LIGHTSABERHWSRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/lightsaberhw_bench.txt: lightsaberhw_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/lightsaber_ext


######## SABER TARGET ########
saber_bench: INCDIR += -I../src/PQClean/crypto_kem/saber/clean
saber_bench: saber_bench.elf slm/saber_bench.txt

saber_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(SABERSRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/saber_bench.txt: saber_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/saber


######## SABERHW TARGET ########
saberhw_bench: INCDIR += -I../src/PQClean/crypto_kem/saber/clean
saberhw_bench: INCDIR += -I$(RISCVOPTPREFIX)/saber
saberhw_bench: saberhw_bench.elf slm/saberhw_bench.txt

saberhw_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(SABERHWSRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/saberhw_bench.txt: saberhw_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/saber_ext


######## FIRESABER TARGET ########
firesaber_bench: INCDIR += -I../src/PQClean/crypto_kem/firesaber/clean
firesaber_bench: firesaber_bench.elf slm/firesaber_bench.txt

firesaber_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(FIRESABERSRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/firesaber_bench.txt: firesaber_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/firesaber


######## FIRESABERHW TARGET ########
firesaberhw_bench: INCDIR += -I../src/PQClean/crypto_kem/firesaber/clean
firesaberhw_bench: INCDIR += -I$(RISCVOPTPREFIX)/lightsaber
firesaberhw_bench: firesaberhw_bench.elf slm/firesaberhw_bench.txt

firesaberhw_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(FIRESABERHWSRCS_C:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/firesaberhw_bench.txt: firesaberhw_bench.srec
	cd slm && $(SRECTOSLM) ../$^; cp spi_stim.txt ../../../TEST/slm_files; cp spi_stim.txt ../../../TEST/slm_files/firesaber_ext


########################
###    Resources     ###
########################

%.srec: %.elf
	$(OBJCOPY) -O srec --srec-len=1 $^ $@

%.siz: %.elf
	$(OBJSIZE) --format=berkeley $^ > $@

%.o: %.c
	$(CC) $(CFLAGS) -Wa,-adhlns="$(@:.o=.o.lst)" -MMD -MP -MF"$(@:.o=.d)" -MT $@ -o $@ -c $< $(INCDIR)

%_asm.o: %.S
	$(AS) $(CFLAGS) -Wa,-adhlns="$(@:.o=.o.lst)" -MMD -MP -MF"$(@:.o=.d)" -MT $@ -o $@ -c $<

%.S: %.c
	$(CC) $(CFLAGS) -o $@ -S $< $(INCDIR)

clean:
	rm -rf $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(LIBSRCS:.c=.o.lst) $(LIBSRCS:.c=.d) $(LIBSRCS_ASM:.S=.d)
	rm -f $(NEWHOPE512SRCS_C:.c=.o) $(NEWHOPE512SRCS_C:.c=.o.lst) $(NEWHOPE512SRCS_C:.c=.d)
	rm -f $(NEWHOPE512HWSRCS_C:.c=.o) $(NEWHOPE512HWSRCS_C:.c=.o.lst) $(NEWHOPE512HWSRCS_C:.c=.d) $(NEWHOPE512HWSRCS:.c=.S)
	rm -f $(NEWHOPE512HWSRCS_ASM:.S=_asm.o) $(NEWHOPE512HWSRCS_ASM:.S=_asm.o.lst) $(NEWHOPE512HWSRCS_ASM:.S=_asm.d)
	rm -f $(NEWHOPE1024SRCS_C:.c=.o) $(NEWHOPE1024SRCS_C:.c=.o.lst) $(NEWHOPE1024SRCS_C:.c=.d)
	rm -f $(NEWHOPE1024HWSRCS_C:.c=.o) $(NEWHOPE1024HWSRCS_C:.c=.o.lst) $(NEWHOPE1024HWSRCS_C:.c=.d) $(NEWHOPE1024HWSRCS:.c=.S)
	rm -f $(NEWHOPE1024HWSRCS_ASM:.S=_asm.o) $(NEWHOPE1024HWSRCS_ASM:.S=_asm.o.lst) $(NEWHOPE1024HWSRCS_ASM:.S=_asm.d)
	rm -f $(KYBER512SRCS_C:.c=.o) $(KYBER512SRCS_C:.c=.o.lst) $(KYBER512SRCS_C:.c=.d) $(KYBERCLEANSRCS:.c=.S)
	rm -f $(KYBER512HWSRCS_C:.c=.o) $(KYBER512HWSRCS_C:.c=.o.lst) $(KYBER512HWSRCS_C:.c=.d) $(KYBERCLEANSRCS:.c=.S)
	rm -f $(KYBER512HWSRCS_ASM:.S=_asm.o) $(KYBER512HWSRCS_ASM:.S=_asm.o.lst) $(KYBER512HWSRCS_ASM:.S=_asm.d)
	rm -f $(KYBER768SRCS_C:.c=.o) $(KYBER768SRCS_C:.c=.o.lst) $(KYBER768SRCS_C:.c=.d) $(KYBERCLEANSRCS:.c=.S)
	rm -f $(KYBER768HWSRCS_C:.c=.o) $(KYBER768HWSRCS_C:.c=.o.lst) $(KYBER768HWSRCS_C:.c=.d) $(KYBERCLEANSRCS:.c=.S)
	rm -f $(KYBER768HWSRCS_ASM:.S=_asm.o) $(KYBER768HWSRCS_ASM:.S=_asm.o.lst) $(KYBER768HWSRCS_ASM:.S=_asm.d)
	rm -f $(KYBER1024SRCS_C:.c=.o) $(KYBER1024SRCS_C:.c=.o.lst) $(KYBER1024SRCS_C:.c=.d) $(KYBERCLEANSRCS_C:.c=.S)
	rm -f $(KYBER1024HWSRCS_C:.c=.o) $(KYBER1024HWSRCS_C:.c=.o.lst) $(KYBER1024HWSRCS_C:.c=.d) $(KYBERCLEANSRCS_C:.c=.S)
	rm -f $(KYBER1024HWSRCS_ASM:.S=_asm.o) $(KYBER1024HWSRCS_ASM:.S=_asm.o.lst) $(KYBER1024HWSRCS_ASM:.S=_asm.d)
	rm -f $(LIGHTSABERSRCS_C:.c=.o) $(LIGHTSABERSRCS_C:.c=.o.lst) $(LIGHTSABERSRCS_C:.c=.d) $(LIGHTSABERSRCS_C:.c=.S)
	rm -f $(LIGHTSABERHWSRCS_C:.c=.o) $(LIGHTSABERHWSRCS_C:.c=.o.lst) $(LIGHTSABERHWSRCS_C:.c=.d) $(LIGHTSABERHWSRCS_C:.c=.S)
	rm -f $(SABERSRCS_C:.c=.o) $(SABERSRCS_C:.c=.o.lst) $(SABERSRCS_C:.c=.d) $(SABERSRCS_C:.c=.S)
	rm -f $(SABERHWSRCS_C:.c=.o) $(SABERHWSRCS_C:.c=.o.lst) $(SABERHWSRCS_C:.c=.d) $(SABERHWSRCS_C:.c=.S)
	rm -f $(FIRESABERSRCS_C:.c=.o) $(FIRESABERSRCS_C:.c=.o.lst) $(FIRESABERSRCS_C:.c=.d) $(FIRESABERSRCS_C:.c=.S)
	rm -f $(FIRESABERHWSRCS_C:.c=.o) $(FIRESABERHWSRCS_C:.c=.o.lst) $(FIRESABERHWSRCS_C:.c=.d) $(FIRESABERHWSRCS_C:.c=.S)
	rm -f *.elf *.srec *.siz *.map
	rm -f slm/flash_stim.slm
	rm -f slm/l2_ram_cut0_hi.slm
	rm -f slm/l2_ram_cut0_lo.slm
	rm -f slm/l2_stim.slm
	rm -f slm/spi_stim.txt
	rm -f slm/tcdm_bank0.slm
