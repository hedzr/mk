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



NAME           ?= me-cli
PACKAGE_NAME   ?= github.com/hedzr/me-cli	# for golang project
ENTRY_PKG      ?= ./cli/me					# for golang project

# platform = $(COS), ARCH = $(ARCH)
PLATFORM       ?= linux
ARCH           ?= amd64
BUILD_DIR      ?= bin
LOGS_DIR       ?= ./logs

GO             := $(shell which go)
GOOS           := $(shell go env GOOS)
GOARCH         := $(shell go env GOARCH)
GOPROXY        := $(shell go env GOPROXY)
GOVERSION      := $(shell go version)
DEFAULT_TARGET := $(GOOS)-$(GOARCH)
W_PKG          := github.com/hedzr/cmdr/v2/conf
CMDR_SETTING   := \
	-X '$(W_PKG).Buildstamp=$(TIMESTAMP)' \
	-X '$(W_PKG).Githash=$(GIT_REVISION)' \
	-X '$(W_PKG).GitSummary=$(GIT_SUMMARY)' \
	-X '$(W_PKG).GitDesc=$(GIT_DESC)' \
	-X '$(W_PKG).BuilderComments=$(BUILDER_COMMENT)' \
	-X '$(W_PKG).GoVersion=$(GOVERSION)' \
	-X '$(W_PKG).Version=$(GIT_VERSION)' \
	-X '$(W_PKG).AppName=$(NAME)'
GOBUILD := CGO_ENABLED=0 \
	$(GO) build \
	-tags "cmdr sec" \
	-trimpath \
	-ldflags="-s -w $(CMDR_SETTING)" \
	-o $(BUILD_DIR)





.PHONY: all $(BUILD_DIR)/$(NAME) release release-all test build
all: build
normal: clean $(BUILD_DIR)/$(NAME)

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.zip

## test: run go test
test: cov
## cov: run go coverage
cov: | $(LOGS_DIR)
	@$(HEADLINE) "Running go coverage..."
	$(GO) test ./... -v -race -cover -coverprofile=$(LOGS_DIR)/coverage-cl.txt -covermode=atomic -test.short -vet=off 2>&1 | tee $(LOGS_DIR)/cover-cl.log && echo "RET-CODE OF TESTING: $?"

$(LOGS_DIR):
	@mkdir -pv $@

.PHONY: directories
directories: | $(BUILD_DIR) $(LOGS_DIR)

## build: build executable for current OS and CPU (arch)
build: $(BUILD_DIR)/$(NAME)
	@echo BUILD $(BUILD_DIR)/$(NAME) OK

## build-default: build the default executable for $(DEFAULT_TARGET)
build-default: $(DEFAULT_TARGET)
	@echo BUILD $(DEFAULT_TARGET) OK

# app: build executable for current GOOS & GOARCH
app: cmdr
# cmdr: build executable for the TARGET GOOS & GOARCH (see also PLATFORM & ARCH vars)
cmdr:
	@-$(MAKE) $(BUILD_DIR)/$(NAME) GOOS=$(PLATFORM) GOARCH=$(ARCH) 

# bin/cmdr is the default executable for running under your current GOOS & GOARCH.
# But you can override them and cross-build whatever targets you want, just like
# what `make app` does.
$(BUILD_DIR)/$(NAME): deps | $(BUILD_DIR)
	@# mkdir -p $(BUILD_DIR)
	$(GOBUILD) $(ENTRY_PKG)
	$(LL) $(BUILD_DIR)/$(NAME)

run:
	echo CGO_ENABLED=0 \
	  $(GO) run \
	    -tags "cmdr sec" \
	    -trimpath \
	    -ldflags="-s -w $(CMDR_SETTING)" \
	    ./ --version

# install: install executable with 'make INSTALL=1 install'
install:
	@$(INSTALL_CMD) mkdir -pv $(INSTALL_PREFIX)/etc/$(NAME)
	@$(INSTALL_CMD) mkdir -pv $(INSTALL_PREFIX)/share/$(NAME)
	@$(INSTALL_CMD) cp $(BUILD_DIR)/$(NAME) $(INSTALL_PREFIX)/bin/$(NAME)
	# @$(INSTALL_CMD) cp example/*.json $(INSTALL_PREFIX)/etc/$(NAME)
	# @$(INSTALL_CMD) cp example/$(NAME).service $(INSTALL_PREFIX)/lib/systemd/system/
	# @$(INSTALL_CMD) cp example/$(NAME)@.service $(INSTALL_PREFIX)/lib/systemd/system/
	# @$(INSTALL_CMD) systemctl daemon-reload
	# @$(INSTALL_CMD) ln -fs $(INSTALL_PREFIX)/share/$(NAME)/geoip.dat /usr/bin/
	# @$(INSTALL_CMD) ln -fs $(INSTALL_PREFIX)/share/$(NAME)/geoip-only-cn-private.dat /usr/bin/
	# @$(INSTALL_CMD) ln -fs $(INSTALL_PREFIX)/share/$(NAME)/geosite.dat /usr/bin/
	@$(INSTALL_HELP)

# uninstall: uninstall executable with 'make UNINSTALL=1 uninstall'
uninstall:
	# @$(UNINSTALL_CMD) rm $(INSTALL_PREFIX)/lib/systemd/system/$(NAME).service
	# @$(UNINSTALL_CMD) rm $(INSTALL_PREFIX)/lib/systemd/system/$(NAME)@.service
	# @$(UNINSTALL_CMD) systemctl daemon-reload
	@$(UNINSTALL_CMD) rm $(INSTALL_PREFIX)/bin/$(NAME)
	@$(UNINSTALL_CMD) rm -rd $(INSTALL_PREFIX)/etc/$(NAME)
	@$(UNINSTALL_CMD) rm -rd $(INSTALL_PREFIX)/share/$(NAME)
	@$(UNINSTALL_HELP)

%.zip: %
	@zip -du $(NAME)-$@ -j $(BUILD_DIR)/$</*
	# @zip -du $(NAME)-$@ example/*
	# @-zip -du $(NAME)-$@ *.dat
	@echo "<<< ---- $(NAME)-$@"

# release: release the final executables for the major platforms
release: \
	darwin-amd64.zip darwin-arm64.zip \
	linux-amd64.zip linux-arm64.zip \
	windows-amd64.zip windows-arm64.zip
	$(LL) $(NAME)-*.*

# release-all: release the final executables for the MOST OF platforms
release-all: darwin-arm64.zip linux-386.zip linux-amd64.zip \
	linux-arm.zip linux-armv5.zip linux-armv6.zip linux-armv7.zip linux-armv8.zip \
	linux-mips-softfloat.zip linux-mips-hardfloat.zip linux-mipsle-softfloat.zip linux-mipsle-hardfloat.zip \
	linux-mips64.zip linux-mips64le.zip \
	freebsd-386.zip freebsd-amd64.zip \
	windows-386.zip windows-amd64.zip windows-arm.zip windows-armv6.zip \
	windows-armv7.zip windows-arm64.zip

#
#
#

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
