
# Invoke ld.lld (Unix), ld64.lld (macOS), lld-link (Windows), wasm-ld (WebAssembly) instead

LLVM            =
OBJDUMP         = objdump
READELF         = readelf
NM              = nm
AR              = ar
CC              = gcc
CXX             = g++
CLANG_TIDY      = clang-tidy
CLANG_FORMAT    = clang-format
CCTYPE          = gcc

ifeq ($(USE_CLANG),1)
    CC              = clang
    CXX             = clang++
endif


GCC_PREFIX      =
LLVM_PREFIX     =
BINUTILS_PREFIX =
ifeq ($(COS),WIN64)
    NASM            = nasm.exe
    LLD             = lld-link.exe
    NASM_FMT        = win64
    NASM_FMT_SUFFIX = .exe
else
    NASM = nasm
    ifeq ($(COS),OSX)
        # install gcc-12 with `brew install gcc` or `brew install gcc@12` on your macOS
        GCC_PREFIX      = $(shell brew --prefix gcc)
        LLVM_PREFIX     = $(shell brew --prefix llvm)
        BINUTILS_PREFIX = $(shell brew --prefix binutils)

        CC              = clang
        CXX             = clang++
        CLANG           = clang
        CLANGXX         = clang++
        CCTYPE          = clang
        GCC             = gcc-12
        GXX             = g++-12

        ifneq ($(GCC_PREFIX),)
            # CC=gcc-12
            # CXX=g++-12
            CCTYPE          = gcc
            GCC             = $(GCC_PREFIX)/bin/gcc-12
            GXX             = $(GCC_PREFIX)/bin/g++-12
            CC              = $(GCC_PREFIX)/bin/gcc-12
            CXX             = $(GCC_PREFIX)/bin/g++-12
        endif
        ifneq ($(LLVM_PREFIX),)
            ifneq ($(GCC_PRIOR),1)
                CCTYPE          = llvm
                CLANG           = $(LLVM_PREFIX)/bin/clang
                CLANGXX         = $(LLVM_PREFIX)/bin/clang++
                CC              = $(LLVM_PREFIX)/bin/clang
                CXX             = $(LLVM_PREFIX)/bin/clang++
                LLD             = $(LLVM_PREFIX)/bin/ld64.lld
                OBJDUMP         = $(LLVM_PREFIX)/bin/llvm-objdump
                READELF         = $(LLVM_PREFIX)/bin/llvm-readelf
                NM              = $(LLVM_PREFIX)/bin/llnm-nm
                AR              = $(LLVM_PREFIX)/bin/llnm-ar
                CLANG_TIDY      = $(LLVM_PREFIX)/bin/clang-tidy
            endif
        else
        endif

        CLANG_FORMAT    = $(shell which clang-format)
        
        ifeq ($(OBJDUMP),objdump)
            ifneq ($(BINUTILS_PREFIX),)
                # install gnu objdump with `brew install binutils`
                # or use otool / gobjdump
                # or use llvm-objdump
                OBJDUMP=$(BINUTILS_PREFIX)/bin/objdump
            endif
        endif
        ifeq ($(READELF),readelf)
            ifneq ($(BINUTILS_PREFIX),)
                # install gnu objdump with `brew install binutils`
                READELF=$(BINUTILS_PREFIX)/bin/readelf
            endif
        endif

        NASM_FMT        = macho64
        NASM_FMT_SUFFIX = 

        # macosx_sdk_platform_version = 10.15.0
        # macosx_sdk_platform_version = 11.1.0
        macosx_sdk_platform_version = $(shell xcrun --sdk macosx --show-sdk-version)
    else
        ifeq ($(COS),LINUX)
            LLD             = ld.lld
            NASM_FMT        = elf64
            NASM_FMT_SUFFIX = .elf

            CCTYPE          = gcc
            GCC             = $(shell which gcc)
            GXX             = $(shell which g++)
            CC              = $(GCC)
            CXX             = $(GXX)

            GCC_VER = $(shell $(GCC) -v 2>&1|tail -1)

            LLVM_PREFIX     = $(shell which llvm-link)
            ifneq ($(LLVM_PREFIX),)
                ifneq ($(GCC_PRIOR),1)
                    LLVM_PREFIX     =
                    CCTYPE          = llvm
                    CLANG           = $(shell which clang)
                    CLANGXX         = $(shell which clang++)
                    CC              = $(shell which clang)
                    CXX             = $(shell which clang++)
                    LLD             = $(shell which ld.lld)
                    OBJDUMP         = $(shell which llvm-objdump)
                    NM              = $(shell which llvm-nm)
                    AR              = $(shell which llvm-ar)
                    CLANG_TIDY      = $(shell which clang-tidy)
                    CLANG_FORMAT    = $(shell which clang-format)
                    CLANG_VER       = $(shell $(CLANG) -v 2>&1|head -1)
                endif
            else
            endif

            # LLD             = $(shell which ld.lld)
            OBJDUMP         = $(shell which objdump)
            NM              = $(shell which nm)
            AR              = $(shell which ar)
            CLANG_TIDY      = $(shell which clang-tidy)
        else
            # TODO, other OSes
        endif
    endif

endif



# QEMU_DBG_OPT = -s -S


# NASM_DEBUG_OPT += -g -F dwarf
# NASM_DEBUG_OPT += -g -F macho64
NASM_DEBUG_OPT += -g
ifeq ($(EVAL_MODE),1)
	NASM_DEBUG_OPT += -dEVAL_MODE
endif


