# mk

`mk` provides a set of makefile utilities to simplify your Makefile.

## Getting Started

### Integrating into your project:

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
```

### Sample

A Makefile sample could be:

```makefile
-include ci/mk/detect_env.mk	# setup COS, ARCH
-include ci/mk/detect_cc.mk		# setup NASM, LLD, NASM_FMT, NASM_FMT_SUFFIX, CC, CXX, ....
-include _env.mk				# setup NASM_DEBUG_OPTS, ...
-include _env.local.mk			#    your local tuning

.PHONY: all

all: build image gen-doc

# ... targets here
build:
image:
gen-doc:
install:
clean:

# END OF Makefile ..
-include ci/mk/help.mk			# targets: i info help list
```

Now these targets are ready: i/info/help, list. For example:

```bash
$ make i

> Choose a command run in :

  linker   prints the linker's activities

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

