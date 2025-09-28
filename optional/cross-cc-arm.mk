# https://gist.github.com/Miouyouyou/6ee23eec681b21782b17ec8a45258b87

# Set this variable with the path to your kernel.
# Don't use /usr/src/linux if you're cross-compiling...
MYY_KERNEL_DIR ?= ../linux

# If you're compiling for ARM64, this will be arm64
ARCH ?= arm

# This is the prefix attached to your cross-compiling gcc/ld/... tools
# In my case, gcc is armv7a-hardfloat-linux-gnueabi-gcc
# If you've installed cross-compiling tools and don't know your 
# prefix, just type "arm" in a shell, hit <TAB> twice
#
# If you're compiling from ARM system with the same architecture
# (arm on arm or arm64 on arm64) delete the characters after "?="
CROSS_COMPILE ?= armv7a-hardfloat-linux-gnueabi-

# The modules will be installed in $(INSTALL_MOD_PATH)/lib/...
# That might not be needed at all, if you're replacing the "install"
# command, see below.
INSTALL_MOD_PATH ?= /tmp/RockMyy-Build
INSTALL_PATH     ?= $(INSTALL_MOD_PATH)/boot
INSTALL_HDR_PATH ?= $(INSTALL_MOD_PATH)/usr

# Determine the CFLAGS specific to this compilation unit.
# This will define the MY_SPECIAL_MACRO_NAME variable that can checked
# with #ifdef in the C code to include specific code.
ccflags-y += -I${src}/include -DMY_SPECIAL_MACRO_NAME=1

# Determine what's needed to compile my-driver.o
# Every '.o' file corresponds to a '.c' file.
my-driver-objs := my_source_file.o my_other_source_file.o
my-driver-objs += yet_another_source_file.o

# Replace m by y if you want to integrate it or
# replace it by a configuration option that should be enabled when
# configuring the kernel like obj-$(CONFIG_MY_MODULE)
#
# obj-m will generate the my-driver.ko
# obj-y will integrate the code into the kernel.
obj-m += my-driver.o

all:
	make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) -C $(MYY_KERNEL_DIR) modules

clean:
	make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) -C $(MYY_KERNEL_DIR) clean

# This does a normal installation...
# You could replace this by a scp command that sends the module to
# your ARM system.
install:
	make INSTALL_MOD_PATH=$(INSTALL_MOD_PATH) INSTALL_PATH=$(INSTALL_PATH) INSTALL_HDR_PATH=$(INSTALL_HDR_PATH) M=$(PWD) -C $(MYY_KERNEL_DIR) modules_install
#	scp my-driver.ko 10.100.0.55:/tmp
