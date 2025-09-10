

uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))

# w := z z x x y c x
#
#	@echo " $(sort ($w))"
#	@echo " $(call uniq,$(w))"
