# Makefile
# We are running g++-12, v12.2.0


-include detect_env.mk		# setup COS, ARCH
-include detect_cc.mk		# setup NASM, LLD, NASM_FMT, NASM_FMT_SUFFIX, CC, CXX, ....
-include _env.mk			# setup NASM_DEBUG_OPTS, ...
-include _env.local.mk		#    your local tuning

-include help.mk			# targets: i info help list
