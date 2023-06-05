# mk

`mk` provides a set of makefile utilities to simplify your Makefile.

## Features

```makefile
-include detect_env.mk		# setup COS, ARCH, cross-p TIMESTAMP, ECHO
-include detect_cc.mk		# setup NASM, LLD, NASM_FMT, NASM_FMT_SUFFIX, CC, CXX, ....
-include _env.mk			# setup NASM_DEBUG_OPTS, ...
-include _env.local.mk		#    your local tuning

-include help.mk			# targets: i info help list

# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

#include git.mk				# GIT_VERSION, GIT_REVISION, ...
```

See also [the main Makefile](https://gitlab.com/cxxtool/mk/-/blob/master/Makefile).

## Getting Started

### Integrating into your project

Add `mk` as a git submodule:

```bash
# add as submodule
$ git submodule add https://gitlab.com/cxxtool/mk.git ci/mk
# pull the work copy
$ git submodule update --init --recursive
# remove it
$ git rm --cached ci/mk && rm -rf ci/mk
```

Update `mk` from official upstream:

```bash
$ git submodule update
# Or
$ git submodule update --remote

# After newer commits checked out or pulled, make a commit on parent to confirm the new pointer of it:
git add . && git commit -m 'updated submodule: ci/mk'
```

> see git submodules: <https://git-scm.com/book/en/v2/Git-Tools-Submodules>

### Sample Skeleton

A Makefile sample could be:

```makefile
-include detect_env.mk		# setup COS, ARCH, cross-p TIMESTAMP, ECHO
-include detect_cc.mk		# setup NASM, LLD, NASM_FMT, NASM_FMT_SUFFIX, CC, CXX, ....
-include _env.mk			# setup NASM_DEBUG_OPTS, ...
-include _env.local.mk		#    your local tuning

-include help.mk			# targets: i info help list

# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

#include git.mk				# GIT_VERSION, GIT_REVISION, ...

.PHONY: all build image gen-doc install clean

all: build image gen-doc

# ... targets here

## build: build files (this line shown by make help)
build:
## image: make a disk image
image:
## gen-doc: build docs
gen-doc:
## install: install into local system
install:
## clean: cleanup the intermediete and target files
clean:

# END OF Makefile ..
-include ci/mk/help.mk          # targets: i info help list
```

Now these targets are ready: i/info/help, list. For example:

```bash
$ make i     # or make info or make help

> Choose a command run in:

  build    build files (this line shown by make help)
  image    make a disk image
  ...

> The environment detected:

   Current OS (COS) = OSX, OS = , GCC_PRIOR = 
               Arch = x86_64
 uname -p | -s | -m = i386 | Darwin | x86_64
             CCTYPE = llvm
                gcc = /usr/local/opt/gcc/, gcc version 12.2.0 (Homebrew GCC 12.2.0) 
         llvm clang = /usr/local/opt/llvm/, Homebrew clang version 15.0.3
       CC/GCC/CLANG = /usr/local/opt/llvm/bin/clang | /usr/local/opt/gcc/bin/gcc-12 | /usr/local/opt/llvm/bin/clang
    CXX/GXX/CLANGXX = /usr/local/opt/llvm/bin/clang++ | /usr/local/opt/gcc/bin/g++-12 | /usr/local/opt/llvm/bin/clang++
                LLD = /usr/local/opt/llvm/bin/ld64.lld
            OBJDUMP = /usr/local/opt/llvm/bin/llvm-objdump
            READELF = /usr/local/opt/llvm/bin/llvm-readelf
         CLANG-TIDY = /usr/local/opt/llvm/bin/clang-tidy
       CLANG-FORMAT = /usr/local/bin/clang-format
        NASM Format = macho64 (suffix: )
```

That's it.

### Standard `_env.mk`

It commonly is:

```Makefile
# CC=g++
# OBJDUMP=objdump
# ifeq ($(COS),OSX)
#     # install gcc-12 with `brew install gcc` or `brew install gcc@12` on your macOS
#     CC=g++12
#     CC=$(shell brew --prefix gcc)/bin/gcc-12
#     # install gnu objdump with `brew install binutils`
#     # or use otool / gobjdump
#     # or use llvm-objdump
#     OBJDUMP=$(shell brew --prefix binutils)/bin/objdump
# endif

# Turn off optimizations because we want to be able to follow the assembly.
FLAGS=-O0 -fverbose-asm -no-pie
POST_FLAGS=-Wl,--verbose
# for clang, use -fno-pie or -fpie; for gcc, use -no-pie or -pie
ifneq ($(CCTYPE),gcc)
    FLAGS=-O0 -fverbose-asm -fno-pie
    POST_FLAGS=
endif
```

### Default `CCTYPE`

If possible, we make `llvm` as default, even if you're in macOS and xcode-tool installed.

This feature relys on `brew install llvm` done and `llvm` is ready. Otherwise, Apple clang will be choiced.

The cc detector finds available cc compilers with this order:

1. llvm (brew, or by package manager)
2. gcc 12, 11, ..., (brew, or by package manager)
3. Stocked cc, such as: Apple clang, gcc bundled with Linux Distro, etc..

## Demo

A simplest C++ project can be found at [cxxtool/hello-cxx](https://gitlab.com/cxxtool/hello-cxx/).

You may wonder, seeing its [Makefile](https://gitlab.com/cxxtool/hello-cxx/-/blob/master/Makefile) for writing rules and targets for an C++ program.

## License

Apache 2.0
