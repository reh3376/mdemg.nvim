.PHONY: test test-integration lint format format-check all

test:
	nvim --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/mdemg/ {minimal_init = 'tests/minimal_init.lua'}"

test-integration:
	MDEMG_INTEGRATION=1 nvim --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/integration/ {minimal_init = 'tests/minimal_init.lua'}"

lint:
	luacheck lua/ tests/

format:
	stylua lua/ tests/ plugin/

format-check:
	stylua --check lua/ tests/ plugin/

all: lint format-check test
