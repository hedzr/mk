# Makefile
#

# We are running g++-12, v12.2.0; or g++-14, llvm 12 ~ 14; etc,,

# for old releases of `mk` repo
-include ../../ci/mk/detect_env.mk	#
-include ../../ci/mk/detect_cc.mk	#

# standard includes here #################
-include ../../ci/mk/detect-env.mk		# setup COS, ARCH, cross-p TIMESTAMP, ECHO
-include ../../ci/mk/detect-cc.mk		# setup NASM, LLD, NASM_FMT, NASM_FMT_SUFFIX, CC, CXX, ....
-include ../../ci/mk/git.mk				# GIT_VERSION, GIT_REVISION, ...

-include env.mk							#
-include .env							#
-include .env.local						#
-include _env.mk						# setup NASM_DEBUG_OPTS, ...
-include _env.local.mk					#    your local tuning
# standard includes ends #################

# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

all: build

build: hello

hello: main.cc
	$(CXX) --std=c++11 -o $@ $<

ls: list
list:
	$(LL) .
	@echo '/$(LL)/'


# standard post-includes here ############
-include ../../ci/mk/go-targets.mk		# for golang project
-include ../../ci/mk/help.mk			# targets: i info help list

help-extras:
	@echo
	@echo "              GO = $(GO)"
	@echo "            GOOS = $(GOOS)"
	@echo "          GOARCH = $(GOARCH)"
	@echo "         GOPROXY = $(GOPROXY)"
	@echo
# standard post-includes ends ############
