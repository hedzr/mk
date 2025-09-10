
ifeq ($(TARGET_ARCH_SEL),riscv64)

# riscv64-unknown-elf- or riscv64-linux-gnu-
# perhaps in /opt/riscv/bin
#TOOLPREFIX =

# Try to infer the correct TOOLPREFIX if not set
ifndef TOOLPREFIX
TOOLPREFIX := $(shell if riscv64-unknown-elf-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-elf-'; \
	elif riscv64-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-linux-gnu-'; \
	elif riscv64-unknown-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-linux-gnu-'; \
	elif riscv64-elf-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-elf-'; \
	elif riscv64-unknown-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-'; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find a riscv64 version of GCC/binutils." 1>&2; \
	echo "*** To turn off this error, run 'gmake TOOLPREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
# # For macOS,
# #    brew install riscv64-elf-gcc riscv64-elf-gdb riscv64-elf-binutils
# #  or,
# #    brew install riscv64-unknown-gcc riscv64-unknown-gdb riscv64-unknown-binutils
# # For ubuntu/debian,
# #    sudo apt-get install gcc-riscv64-linux-gnu g++-riscv64-linux-gnu binutils-riscv64-linux-gnu 
# #  or,
# #    sudo apt-get install gcc-riscv64-unknown-gnu binutils-riscv64-unknown-elf
# ifdef macOS
# 	ifeq ($(TOOLPREFIX),riscv64-elf-)
# 		CXXFLAGS += -I$(shell find $(brew --prefix riscv64-elf-gcc)/ -type d -name include)
# 	else
# 	endif
# endif
endif

QEMU = qemu-system-riscv64

STACK_SIZE  = 0xf00

else # TARGET_ARCH_SEL
endif # TARGET_ARCH_SEL

AS          = $(TOOLPREFIX)as
CC          = $(TOOLPREFIX)gcc
CXX         = $(TOOLPREFIX)g++
LD          = $(TOOLPREFIX)ld
RANLIB      = $(TOOLPREFIX)ranlib
GCC_RANLIB  = $(TOOLPREFIX)gcc-ranlib
AR          = $(TOOLPREFIX)ar
GCC_AR      = $(TOOLPREFIX)gcc-ar
NM          = $(TOOLPREFIX)nm
GCC_NM      = $(TOOLPREFIX)gcc-nm
OBJCOPY     = $(TOOLPREFIX)objcopy
OBJDUMP     = $(TOOLPREFIX)objdump
READELF     = $(TOOLPREFIX)readelf
STRINGS     = $(TOOLPREFIX)strings
STRIP       = $(TOOLPREFIX)strip

CC1PLUS     = $(shell $(CXX) -print-prog-name=cc1plus)


ifeq ($(DEBUG_BUILD),1)
  DEBUG_FLAG += -DDEBUG_PRINT=1 -D_DEBUG=1 -DDEBUG=1 \
                -ggdb -Og
  #  -Og -ggdb
  ASFLAGS += -g
  # LDFLAGS += -s
else
  # -Os: optimize for size
  DEBUG_FLAG += -DDEBUG_PRINT=0 -DNODEBUG=1 \
                -Os
  LDFLAGS += -s
endif

ifeq ($(ENABLE_FLOAT),1)
  MARCH   ?= rv64imafdc_zicsr
  MABI    ?= lp64d
else
  MARCH   ?= rv64ima_zicsr
  MABI    ?= lp64
endif

#ifeq ($(ENABLE_EXCEPTION),1)
#  CCFLAGS += -fexceptions
#else
#  CCFLAGS += -fno-exceptions
#endif

# ASFLAGS += -march=rv64ima -mabi=lp64
# ASFLAGS += -march=rv64i
# ASFLAGS += -march=rv64i_zicsr
ASFLAGS += -mabi=$(MABI)
ASFLAGS += -march=$(MARCH)
ASFLAGS += -D__ASSEMBLER_ONLY__=1 -D__ASSEMBLER__

CFLAGS += $(CCFLAGS)
CFLAGS += -Wall -Werror \
		  -Wno-unused-variable
CFLAGS += -ffreestanding -nostdlib -nodefaultlibs -nostartfiles
CFLAGS += -march=$(MARCH) -mabi=$(MABI) -mcmodel=medany -mno-relax
CFLAGS += -fno-omit-frame-pointer -fno-common
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
CFLAGS += $(DEBUG_FLAG)
#CFLAGS += -I./$(DIR_LIBS) -I./$(DIR_INC)
CFLAGS += -MD -MP -MF"${@:%.o=%}.d"

# Disable PIE when possible (for Ubuntu 16.10 toolchain)
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]no-pie'),)
CFLAGS += -fno-pie -no-pie
endif
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]nopie'),)
CFLAGS += -fno-pie -nopie
endif

# -Og -ggdb
# -Os -g
# -ffreestanding 
#	-fno-exceptions
#
# -nodefaultlibs
CXXFLAGS += $(CCFLAGS)
CXXFLAGS += -Wall -Werror \
			-Wno-unused-variable \
			-Wno-unused-label \
			-Wno-array-bounds \
			-Wno-stringop-overflow
CXXFLAGS += -nostdlib -nodefaultlibs -nostartfiles -std=c++20
CXXFLAGS += -march=$(MARCH) -mabi=$(MABI) -mcmodel=medany -mno-relax
ifeq ($(ENABLE_SUPCXX),1)
CXXFLAGS += \
	-fno-rtti -fexceptions
else
CXXFLAGS += \
	-fno-exceptions
endif
CXXFLAGS += \
	-fno-common \
	-fno-omit-frame-pointer \
	-fno-use-cxa-atexit \
	-fno-nonansi-builtins \
	-fno-threadsafe-statics \
	-fno-enforce-eh-specs \
	-ffunction-sections \
	-ftemplate-depth=32 \
	-Wzero-as-null-pointer-constant
#CXXFLAGS += -I./$(DIR_LIBS) -I./$(DIR_INC)
CXXFLAGS += $(shell $(CXX) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
CXXFLAGS += $(DEBUG_FLAG)
# -MMD: no header file list will be printed into target .d file
#       see: https://blog.csdn.net/nawenqiang/article/details/83381237
# CXXFLAGS += -MMD -MP -MF"${@:%.o=%.d}"
CXXFLAGS += -MD -MP -MF"${@:%.o=%}.d"
CXXFLAGS += -Xlinker --defsym=__stack_size=$(STACK_SIZE)
# CXXFLAGS += -Xlinker -Wl,-Map=$@.map
# CXXFLAGS += -Xlinker __BUILD_DATE=$(date --utc +%Y%m%d)
# CXXFLAGS += -Xlinker __BUILD_DATE=$(TIMESTAMP)

LDSCRIPT    := linker.ld
LDFLAGS     += -z max-page-size=4096 --script $(LDSCRIPT)
# LDFLAGS   += -Xlinker --defsym=__stack_size=$(STACK_SIZE) -Wl,-Map=$@.map
LDFLAGS     += --no-dynamic-linker -m elf64lriscv -static -nostdlib
# LDFLAGS   += --defsym=__BUILD_DATE=$(TIMESTAMP)
LDFLAGS     += -Map=$@.map
ifeq ($(ENABLE_SUPCXX),1)
LDFLAGS.    += -lsupc++
endif
# -fno-exceptions
# -Xlinker --defsym=__stack_size=$(STACK_SIZE)
#LDLIBS      += --library-path . $(patsubst %,--library=:%,$(LIBS))
LDEXTRALIBS +=
