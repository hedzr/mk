# Makefile
# We are running g++-12, v12.2.0


-include ../../ci/mk/detect_env.mk	# setup COS, ARCH, cross-p TIMESTAMP, ECHO
-include ../../ci/mk/detect_cc.mk	# setup NASM, LLD, NASM_FMT, NASM_FMT_SUFFIX, CC, CXX, ....
-include ../../ci/mk/git.mk			# GIT_VERSION, GIT_REVISION, ...
-include _env.mk					# setup NASM_DEBUG_OPTS, ...
-include _env.local.mk				#    your local tuning

-include help.mk					# targets: i info help list

# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

all: build

build: hello

hello: main.cc
	$(CXX) --std=c++11 -o $@ $<
