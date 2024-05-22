# MINI_INIT=scripts/minimal_init.lua
# TESTS_DIR=lua-tests/

# .PHONY: test doc

# test:
# 	@nvim \
# 		--headless \
# 		--noplugin \
# 		-u ${MINI_INIT} \
# 		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${MINI_INIT}' }"
#

gen_types:
	@nvim \
		--headless \
		-c "set rtp+=." -l ./scripts/gen_annotation.lua

format:
	stylua --check .
