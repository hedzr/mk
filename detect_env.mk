
# The supported OSes and Architects are: WIN64 (Win X, ...), LINUX (64bit), macOS (64bit).
# You may start building on these platforms.
#
# COS is your working machine (host) for building.
# ARCH is it.

# COS: current OS, could be    : WIN64, LINUX, OSX, 
#      unsupported values      : WIN32, IA32, ARM, ARM64, ...
# ARCH: current Arch, could be : AMD64 (special for win64), x86_64 (for linux and macOS)
#      unsupported values      : x86, arm, ...

# NASM_FMT: for nasm -f <fmt> ...

COS = $(OS)
ifeq ($(OS),Windows_NT)
    COS = WIN32
    ARCH = x86
    LS_OPT=
    CCFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        CCFLAGS += -D AMD64
        COS = WIN64
        ARCH = AMD64
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            CCFLAGS += -D AMD64
            COS = WIN64
            ARCH = AMD64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),x86)
            CCFLAGS += -D IA32
            COS = IA32
        endif
    endif
else
    LS_OPT=
    UNAME_S := $(shell uname -s)
    ARCH = $(shell uname -m)
    ifeq ($(UNAME_S),Linux)
        CCFLAGS += -D LINUX
        LS_OPT=--color
        COS = LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        CCFLAGS += -D OSX
        LS_OPT=-G
        COS = OSX
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        CCFLAGS += -D AMD64
    else
        ifneq ($(filter %86,$(UNAME_P)),)
            CCFLAGS += -D IA32
        endif
        ifneq ($(filter arm%,$(UNAME_P)),)
            CCFLAGS += -D ARM
            ARCH = ARM
            # todo for arm, aarch, risc-v, ...
        endif
    endif
endif


#TIMESTAMP=$(shell date)
#TIMESTAMP=$(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
TIMESTAMP=$(shell date -u '+%Y-%mm-%ddT%HH:%MM:%SS')
ifeq ($(OS),macOS)
	TIMESTAMP=$(shell date -Iseconds)
endif

ECHO = echo -e
ifeq ($(OS),macOS)
	ECHO = echo
endif
