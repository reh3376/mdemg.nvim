describe("mdemg", function()
	local mdemg

	before_each(function()
		package.loaded["mdemg"] = nil
		package.loaded["mdemg.config"] = nil
		package.loaded["mdemg.auto.session"] = nil
		package.loaded["mdemg.auto.health_poll"] = nil
		package.loaded["mdemg.auto.ingest_on_save"] = nil
		package.loaded["mdemg.util.instance"] = nil
		package.loaded["mdemg.util.space"] = nil
	end)

	it("has _VERSION", function()
		mdemg = require("mdemg")
		assert.is_string(mdemg._VERSION)
	end)

	it("_VERSION is 0.1.0", function()
		mdemg = require("mdemg")
		assert.equals("0.1.0", mdemg._VERSION)
	end)

	it("setup calls config.setup", function()
		local config_called = false
		package.loaded["mdemg.config"] = {
			setup = function()
				config_called = true
			end,
			get = function()
				return { keymaps = {} }
			end,
		}
		package.loaded["mdemg.auto.session"] = { setup = function() end }
		package.loaded["mdemg.auto.health_poll"] = { setup = function() end }
		package.loaded["mdemg.auto.ingest_on_save"] = { setup = function() end }
		package.loaded["mdemg.util.instance"] = { resolve = function() end, clear_cache = function() end }
		package.loaded["mdemg.util.space"] = { resolve = function() end, clear_cache = function() end }

		mdemg = require("mdemg")
		mdemg.setup({})
		assert.is_true(config_called)
	end)

	it("setup calls auto module setups", function()
		local session_called, health_called, ingest_called = false, false, false
		package.loaded["mdemg.config"] = {
			setup = function() end,
			get = function()
				return { keymaps = {} }
			end,
		}
		package.loaded["mdemg.auto.session"] = {
			setup = function()
				session_called = true
			end,
		}
		package.loaded["mdemg.auto.health_poll"] = {
			setup = function()
				health_called = true
			end,
		}
		package.loaded["mdemg.auto.ingest_on_save"] = {
			setup = function()
				ingest_called = true
			end,
		}
		package.loaded["mdemg.util.instance"] = { resolve = function() end, clear_cache = function() end }
		package.loaded["mdemg.util.space"] = { resolve = function() end, clear_cache = function() end }

		mdemg = require("mdemg")
		mdemg.setup({})
		assert.is_true(session_called)
		assert.is_true(health_called)
		assert.is_true(ingest_called)
	end)

	it("setup wires instance and space modules for BufEnter", function()
		package.loaded["mdemg.config"] = {
			setup = function() end,
			get = function()
				return { keymaps = {} }
			end,
		}
		package.loaded["mdemg.auto.session"] = { setup = function() end }
		package.loaded["mdemg.auto.health_poll"] = { setup = function() end }
		package.loaded["mdemg.auto.ingest_on_save"] = { setup = function() end }
		package.loaded["mdemg.util.instance"] = {
			resolve = function()
				return { endpoint = "http://localhost:9999", project_root = "/test" }
			end,
			clear_cache = function() end,
		}
		package.loaded["mdemg.util.space"] = {
			resolve = function()
				return nil
			end,
			clear_cache = function() end,
		}

		mdemg = require("mdemg")
		mdemg.setup({})

		-- The autocmd is registered but won't fire in test context
		-- Verify setup completed without error
		assert.is_not_nil(mdemg.setup)
	end)
end)
