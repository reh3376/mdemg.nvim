describe("mdemg.util.space", function()
	local space
	local mock_getftime

	before_each(function()
		package.loaded["mdemg.util.space"] = nil
		package.loaded["mdemg.util.config_reader"] = nil
		package.loaded["mdemg.config"] = nil

		-- Mock config_reader — default: return nil (no config file)
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return nil
			end,
		}

		-- Setup mdemg.config with no space_id
		local config = require("mdemg.config")
		config.setup({})

		-- Clear env
		vim.env.MDEMG_SPACE_ID = nil

		-- Default mock: config file does not exist (mtime = -1)
		mock_getftime = -1
		vim.fn.getftime = function()
			return mock_getftime
		end

		space = require("mdemg.util.space")
	end)

	after_each(function()
		vim.env.MDEMG_SPACE_ID = nil
	end)

	it("returns nil for nil project_root", function()
		assert.is_nil(space.resolve(nil))
	end)

	it("returns space_id from config.yaml space_id field", function()
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return { space_id = "from-yaml" }
			end,
		}
		local result = space.resolve("/some/project")
		assert.equals("from-yaml", result)
	end)

	it("returns space_id from config.yaml nested space.id field", function()
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return { space = { id = "nested-id" } }
			end,
		}
		local result = space.resolve("/another/project")
		assert.equals("nested-id", result)
	end)

	it("falls back to MDEMG_SPACE_ID env var", function()
		vim.env.MDEMG_SPACE_ID = "env-space"
		local result = space.resolve("/env/project")
		assert.equals("env-space", result)
	end)

	it("falls back to config.get().space_id", function()
		package.loaded["mdemg.config"] = nil
		local config = require("mdemg.config")
		config.setup({ space_id = "config-space" })

		local result = space.resolve("/cfg/project")
		assert.equals("config-space", result)
	end)

	it("returns nil instead of basename when no source provides space_id", function()
		local result = space.resolve("/home/user/my-project")
		assert.is_nil(result)
	end)

	it("does not cache nil result", function()
		local result = space.resolve("/home/user/no-space")
		assert.is_nil(result)
		assert.is_nil(space._cache["/home/user/no-space"])

		-- Now add a source — should resolve on next call
		vim.env.MDEMG_SPACE_ID = "fixed-space"
		local result2 = space.resolve("/home/user/no-space")
		assert.equals("fixed-space", result2)
	end)

	it("returns cached value on second call with same mtime", function()
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return { space_id = "cached-val" }
			end,
		}
		mock_getftime = 1000

		local result1 = space.resolve("/home/user/cached-project")
		assert.equals("cached-val", result1)

		-- Change the mock — should NOT affect result due to cache (same mtime)
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return { space_id = "should-not-see-this" }
			end,
		}

		local result2 = space.resolve("/home/user/cached-project")
		assert.equals("cached-val", result2)
	end)

	it("invalidates cache when config mtime changes", function()
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return { space_id = "original" }
			end,
		}
		mock_getftime = 1000

		local result1 = space.resolve("/home/user/mtime-project")
		assert.equals("original", result1)

		-- Simulate config file edit — mtime changes
		mock_getftime = 2000
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return { space_id = "updated" }
			end,
		}

		local result2 = space.resolve("/home/user/mtime-project")
		assert.equals("updated", result2)
	end)

	it("clears cache", function()
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return { space_id = "clearme-val" }
			end,
		}
		space.resolve("/home/user/clearme")
		assert.is_not_nil(space._cache["/home/user/clearme"])

		space.clear_cache()
		assert.same({}, space._cache)
	end)
end)
