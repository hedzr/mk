
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


# ifeq ($(OS),Windows_NT)
#     LS_OPT=
#     CCFLAGS += -D WIN32
#     ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
#         CCFLAGS += -D AMD64
#     else
#         ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
#             CCFLAGS += -D AMD64
#         endif
#         ifeq ($(PROCESSOR_ARCHITECTURE),x86)
#             CCFLAGS += -D IA32
#         endif
#     endif
# else
#     LS_OPT=
#     UNAME_S := $(shell uname -s)
#     ifeq ($(UNAME_S),Linux)
#         OS = Linux
#         CCFLAGS += -D LINUX
#         LS_OPT=--color
#     endif
#     ifeq ($(UNAME_S),Darwin)
#         OS = macOS
#         CCFLAGS += -D OSX
#         LS_OPT=-G
#     endif
#     UNAME_P := $(shell uname -p)
#     ifeq ($(UNAME_P),x86_64)
#         CCFLAGS += -D AMD64
#     endif
#     ifneq ($(filter %86,$(UNAME_P)),)
#         CCFLAGS += -D IA32
#     endif
#     ifneq ($(filter arm%,$(UNAME_P)),)
#         CCFLAGS += -D ARM
#     endif
# endif



COS = $(OS)
ifeq ($(OS),Windows_NT)
	COS   = WIN32
	ARCH  = x86
	ARCH_ = i386
	LS_OPT=
	CCFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CCFLAGS += -D AMD64
		COS   = WIN64
		ARCH  = AMD64
		ARCH_ = x86_64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CCFLAGS += -D AMD64
			COS = WIN64
			ARCH = AMD64
			ARCH_ = x86_64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),ARM64)
			CCFLAGS += -D ARM64
			COS = WIN64
			ARCH = ARM64
			ARCH_ = aarch64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CCFLAGS += -D IA32
			COS = WIN32
		endif
	endif
else
	LS_OPT=
	# uname -s: Darwin, Linux, ...
	# uname -m: arm64/amd64 (for Darwin), aarch64/x86_64 (for Linux) ...
	# uname -p: arm64/amd64 (for Darwin), aarch64/x86_64 (for Linux) ...
	UNAME_S := $(shell uname -s)
	UNAME_M := $(shell uname -m)
	ARCH     = $(UNAME_M)
	ARCH_    = $(UNAME_M)
	ifeq ($(UNAME_S),Linux)
		CCFLAGS += -D LINUX
		LS_OPT   = --color
		COS      = LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		CCFLAGS += -D OSX
		LS_OPT   = -G
		COS      = OSX
	endif
	UNAME_P := $(shell uname -p)
    ifneq ($(UNAME_S),Darwin)
		ifeq ($(UNAME_P),x86_64)
			CCFLAGS += -D AMD64
		else
			ifneq ($(filter %86,$(UNAME_P)),)
				CCFLAGS += -D IA32
			endif
			ifneq ($(filter riscv64%,$(UNAME_P)),)
				CCFLAGS += -D RISCV -D RISCV64
				ARCH = RISCV64
				ARCH_ = riscv64
			endif
			ifneq ($(filter riscv%,$(UNAME_P)),)
				CCFLAGS += -D RISCV -D RISCV32
				ARCH = RISCV32
				ARCH_ = riscv32
			endif
			ifneq ($(filter aarch64%,$(UNAME_P)),)
				CCFLAGS += -D ARM64 -D AARCH64
				ARCH = ARM64
				ARCH_ = aarch64
			endif
			ifneq ($(filter arm64%,$(UNAME_P)),)
				CCFLAGS += -D ARM64 -D AARCH64
				ARCH = ARM64
				ARCH_ = arm64
			endif
			ifneq ($(filter arm%,$(UNAME_P)),)
				CCFLAGS += -D ARM -D ARM32
				ARCH = ARM
				# todo for arm, aarch, risc-v, ...
			endif
		endif
	endif
endif


CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)


INSTALL            ?= 0
UNINSTALL          ?= 0
ifeq (INSTALL,1)
  INSTALL_CMD      :=
  UNINSTALL_CMD    :=
  INSTALL_HELP     := 
  UNINSTALL_HELP   := 
else
  INSTALL_CMD      := echo
  UNINSTALL_CMD    := echo
  INSTALL_HELP     := @printf "\n\e[0;38;2;133;133;133m>>> %s\e[0m\n" "Use 'make INSTALL=1 install' to commit installing action to your local system."
  UNINSTALL_HELP   := @printf "\n\e[0;38;2;133;133;133m>>> %s\e[0m\n" "Use 'make UNINSTALL=1 install' to commit installing action to your local system."
endif
INSTALL_PREFIX     := /usr/local
LS_OPT             := --color
TIMESTAMP          := $(shell date -u '+%Y-%m-%dT%H:%M:%S.%N')
# TIMESTAMP        := $(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
# TIMESTAMP        := $(shell date -u '+%Y-%mm-%ddT%HH:%MM:%SS')
ECHO = echo -e

ifeq ($(COS),OSX)
    INSTALL_PREFIX := $(shell brew --prefix)
    LS_OPT         := -G
	TIMESTAMP      := $(shell date -Iseconds)
	ECHO           := echo
endif

LS                 := ls $(LS_OPT)
LL                 := ls -la $(LS_OPT)
LA                 := ls -la $(LS_OPT)
M                  := $(shell printf "\033[34;1m▶\033[0m")

TIP                := printf "\e[0;38;2;133;133;133m>>> %s\e[0m\n"
ERR                := printf "\e[0;33;1;133;133;133m>>> %s\e[0m\n"
DBG                := printf ">>> \e[0;38;2;133;133;133m%s\e[0m\n"
HEADLINE           := printf "\e[0;1m%s\e[0m:\n"
MM                 := printf "\033[34;1m▶\033[0m %s\e[0m\n"
