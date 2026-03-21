describe("mdemg.ui.statusline", function()
	local statusline

	before_each(function()
		package.loaded["mdemg.ui.statusline"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ statusline = { icons = false, format = "short" } })

		statusline = require("mdemg.ui.statusline")
	end)

	describe("_state", function()
		it("starts disconnected", function()
			assert.is_false(statusline._state.connected)
		end)

		it("starts with nil space_id", function()
			assert.is_nil(statusline._state.space_id)
		end)

		it("starts with nil node_count", function()
			assert.is_nil(statusline._state.node_count)
		end)
	end)

	describe("update_state", function()
		it("merges new state fields", function()
			statusline.update_state({ connected = true, space_id = "test-space" })
			assert.is_true(statusline._state.connected)
			assert.equals("test-space", statusline._state.space_id)
		end)

		it("preserves unmodified fields", function()
			statusline.update_state({ connected = true })
			statusline.update_state({ space_id = "my-space" })
			assert.is_true(statusline._state.connected)
			assert.equals("my-space", statusline._state.space_id)
		end)
	end)

	describe("component", function()
		it("shows [M!] when disconnected (no icons)", function()
			statusline.update_state({ connected = false })
			local result = statusline.component()
			assert.equals("[M!]", result)
		end)

		it("shows [M] when connected (no icons)", function()
			statusline.update_state({ connected = true })
			local result = statusline.component()
			assert.equals("[M]", result)
		end)

		it("includes space_id in short format", function()
			statusline.update_state({ connected = true, space_id = "dev" })
			local result = statusline.component()
			assert.equals("[M] dev", result)
		end)

		it("includes node_count in short format", function()
			statusline.update_state({ connected = true, space_id = "dev", node_count = 150 })
			local result = statusline.component()
			assert.equals("[M] dev 150", result)
		end)

		it("shows health percentage in long format", function()
			package.loaded["mdemg.config"] = nil
			local config = require("mdemg.config")
			config.setup({ statusline = { icons = false, format = "long" } })

			statusline.update_state({
				connected = true,
				space_id = "prod",
				node_count = 500,
				health_score = 0.85,
			})
			local result = statusline.component()
			assert.equals("[M] prod 500n 85%", result)
		end)

		it("shows emoji icons when icons enabled", function()
			package.loaded["mdemg.config"] = nil
			local config = require("mdemg.config")
			config.setup({ statusline = { icons = true, format = "short" } })

			statusline.update_state({ connected = true })
			local result = statusline.component()
			-- Should start with brain emoji, not [M]
			assert.is_truthy(result:find("\xf0\x9f\xa7\xa0"))
		end)

		it("shows skull emoji when disconnected with icons", function()
			package.loaded["mdemg.config"] = nil
			local config = require("mdemg.config")
			config.setup({ statusline = { icons = true, format = "short" } })

			statusline.update_state({ connected = false })
			local result = statusline.component()
			assert.is_truthy(result:find("\xf0\x9f\x92\x80"))
		end)
	end)

	describe("color", function()
		it("returns red when disconnected", function()
			statusline.update_state({ connected = false })
			local c = statusline.color()
			assert.equals("#ff5555", c.fg)
		end)

		it("returns yellow when connected but stale", function()
			statusline.update_state({ connected = true, freshness = { is_stale = true } })
			local c = statusline.color()
			assert.equals("#f1fa8c", c.fg)
		end)

		it("returns green when connected and fresh", function()
			statusline.update_state({ connected = true, freshness = { is_stale = false } })
			local c = statusline.color()
			assert.equals("#50fa7b", c.fg)
		end)

		it("returns green when connected with no freshness data", function()
			statusline.update_state({ connected = true })
			local c = statusline.color()
			assert.equals("#50fa7b", c.fg)
		end)
	end)
end)
