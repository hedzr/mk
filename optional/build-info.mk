

## build-info: produces building info to DIR_BUILD/build-info/
build-info: | $(DIR_BUILD)
	$(eval DIR_BUILD_INFO := $(DIR_BUILD)/build-info)

	@[ -d "$(DIR_BUILD_INFO)" ] || mkdir -pv "$(DIR_BUILD_INFO)"
	
	@echo "## CXXFLAGS" >  $(DIR_BUILD_INFO)/build-info
	@echo $(CXXFLAGS)   >  $(DIR_BUILD_INFO)/build-flags
	@cat  $(DIR_BUILD_INFO)/build-flags >>$(DIR_BUILD_INFO)/build-info
	@echo "#ifndef BI_DEFINITIONS"  > $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_DEFINITIONS"  >> $(DIR_BUILD_INFO)/build-info.hh
	@echo >> $(DIR_BUILD_INFO)/build-info.hh
	@echo >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "/* Building Information Here. */" >> $(DIR_BUILD_INFO)/build-info.hh
	@echo >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_CXXFLAGS    \"$(CXXFLAGS)\""  >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_CFLAGS      \"$(CFLAGS)\""    >> $(DIR_BUILD_INFO)/build-info.hh
	
	@echo >> $(DIR_BUILD_INFO)/build-info
	@echo "## Headers" >> $(DIR_BUILD_INFO)/build-info
	@#$(CC1PLUS) -v | awk '/,/' > $(DIR_BUILD_INFO)/build-incs
	@$(CXX) -E -Wp,-v -xc++ /dev/null 2>&1 | sed -n '/#include </,/End of search list./p' > $(DIR_BUILD_INFO)/build-incs
	@cat $(DIR_BUILD_INFO)/build-incs >>$(DIR_BUILD_INFO)/build-info

	@echo >> $(DIR_BUILD_INFO)/build-info
	@echo "## Builder Version" >> $(DIR_BUILD_INFO)/build-info
	@$(CXX) --version > $(DIR_BUILD_INFO)/builder-version
	@cat $(DIR_BUILD_INFO)/builder-version >>$(DIR_BUILD_INFO)/build-info
	@echo >> $(DIR_BUILD_INFO)/build-info
	@echo "## Buidler Ver" >> $(DIR_BUILD_INFO)/build-info
	@$(CXX) -v &> $(DIR_BUILD_INFO)/builder-ver
	@cat $(DIR_BUILD_INFO)/builder-ver >>$(DIR_BUILD_INFO)/build-info
	@echo "#define BI_CXX_INCS    \"${shell $(CXX) -E -Wp,-v -xc++ /dev/null 2>&1 | sed -n '/#include </,/End of search list./p'}\""  >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_CXX_VER     \"${shell $(CXX) -v 2>&1}\""               >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_CXX_VERSION \"${shell $(CXX) --version}\""        >> $(DIR_BUILD_INFO)/build-info.hh
	
	@echo >> $(DIR_BUILD_INFO)/build-info
	@echo "## VCS Info" >> $(DIR_BUILD_INFO)/build-info
	@# git show --oneline -s > $(DIR_BUILD_INFO)/git-log-1
	@git log -1 --oneline > $(DIR_BUILD_INFO)/git-log-1
	@git rev-parse --short HEAD > $(DIR_BUILD_INFO)/git-commit-hash
	@{ git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0; } > $(DIR_BUILD_INFO)/git-describe
	@cat $(DIR_BUILD_INFO)/git-log-1       >>$(DIR_BUILD_INFO)/build-info
	@cat $(DIR_BUILD_INFO)/git-commit-hash >>$(DIR_BUILD_INFO)/build-info
	@cat $(DIR_BUILD_INFO)/git-describe    >>$(DIR_BUILD_INFO)/build-info
	@echo "#define BI_VCS_LOG_1   \"${shell git log -1 --oneline}\""  >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_VCS_HASH    \"${shell git rev-parse --short HEAD}\""  >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_VCS_DESCRIB \"${shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0 }\""  >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_TIMESTAMP   \"$(TIMESTAMP)\""  >> $(DIR_BUILD_INFO)/build-info.hh
	
	@echo >> $(DIR_BUILD_INFO)/build-info
	@echo "## Build Time" >> $(DIR_BUILD_INFO)/build-info
	@echo "$(TIMESTAMP)" >> $(DIR_BUILD_INFO)/build-info
	
	@echo >> $(DIR_BUILD_INFO)/build-info
	@echo "## Build OS & Arch" >> $(DIR_BUILD_INFO)/build-info
	@echo "$(COS)" >> $(DIR_BUILD_INFO)/build-info
	@echo "$(ARCH)" >> $(DIR_BUILD_INFO)/build-info
	@echo "#define BI_OS          \"$(COS)\""  >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#define BI_ARCH        \"$(ARCH)\""  >> $(DIR_BUILD_INFO)/build-info.hh
	@echo >> $(DIR_BUILD_INFO)/build-info.hh
	@echo >> $(DIR_BUILD_INFO)/build-info.hh
	@echo "#endif /* BI_DEFINITIONS */"  >> $(DIR_BUILD_INFO)/build-info.hh

	@which xxd &>/dev/null && xxd -i $(DIR_BUILD_INFO)/build-info >$(DIR_BUILD_INFO)/build-info.c

	@echo "... end of $@ - done"
	@# REF: https://stackoverflow.com/questions/70556464/can-you-get-the-compilers-command-line-contents-from-within-the-compiled-progra
