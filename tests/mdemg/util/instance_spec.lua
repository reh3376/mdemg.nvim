describe("mdemg.util.instance", function()
	local instance

	before_each(function()
		package.loaded["mdemg.util.instance"] = nil
		package.loaded["mdemg.util.config_reader"] = nil
		package.loaded["mdemg.config"] = nil

		-- Mock config_reader — default: return nil (no config file)
		package.loaded["mdemg.util.config_reader"] = {
			read = function()
				return nil
			end,
		}

		-- Setup mdemg.config with default endpoint
		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		-- Clear env
		vim.env.MDEMG_ENDPOINT = nil

		instance = require("mdemg.util.instance")
	end)

	after_each(function()
		vim.env.MDEMG_ENDPOINT = nil
	end)

	it("returns nil for nil path", function()
		assert.is_nil(instance.resolve(nil))
	end)

	it("returns nil for empty path", function()
		assert.is_nil(instance.resolve(""))
	end)

	it("returns cached result on second call via prefix match", function()
		instance._cache["/some/project"] = {
			endpoint = "http://cached:1234",
			project_root = "/some/project",
		}
		local result = instance.resolve("/some/project/src/file.go")
		assert.equals("http://cached:1234", result.endpoint)
		assert.equals("/some/project", result.project_root)
	end)

	it("cache prefix match is exact on root key", function()
		instance._cache["/some/proj"] = {
			endpoint = "http://cached:1234",
			project_root = "/some/proj",
		}
		-- "/some/project-other/file.go" starts with "/some/proj" so it matches
		-- This tests the substring prefix behavior of the cache
		local result = instance.resolve("/some/proj/deep/file.go")
		assert.equals("http://cached:1234", result.endpoint)
	end)

	it("clears cache", function()
		instance._cache["/test"] = {
			endpoint = "http://test:1234",
			project_root = "/test",
		}
		instance.clear_cache()
		assert.same({}, instance._cache)
	end)

	it("starts with empty cache", function()
		assert.same({}, instance._cache)
	end)

	it("returns nil when no .mdemg directory found", function()
		local orig_isdir = vim.fn.isdirectory
		vim.fn.isdirectory = function()
			return 0
		end

		local result = instance.resolve("/some/deep/nested/file.go")

		vim.fn.isdirectory = orig_isdir
		assert.is_nil(result)
	end)

	it("uses MDEMG_ENDPOINT env var when .mdemg dir exists but no config", function()
		vim.env.MDEMG_ENDPOINT = "http://env-endpoint:7777"

		local orig_isdir = vim.fn.isdirectory
		local orig_filereadable = vim.fn.filereadable
		local orig_fnamemodify = vim.fn.fnamemodify

		-- Simulate .mdemg dir at /fakedir
		vim.fn.isdirectory = function(path)
			if path == "/fakedir/.mdemg" then
				return 1
			end
			return 0
		end
		vim.fn.filereadable = function()
			return 0
		end
		vim.fn.fnamemodify = function(path, mod)
			if mod == ":p:h" then
				return "/fakedir"
			end
			if mod == ":h" then
				if path == "/fakedir" then
					return "/"
				end
				return orig_fnamemodify(path, mod)
			end
			return orig_fnamemodify(path, mod)
		end

		local result = instance.resolve("/fakedir/src/main.go")

		vim.fn.isdirectory = orig_isdir
		vim.fn.filereadable = orig_filereadable
		vim.fn.fnamemodify = orig_fnamemodify

		assert.is_not_nil(result)
		assert.equals("http://env-endpoint:7777", result.endpoint)
		assert.equals("/fakedir", result.project_root)
	end)

	it("falls back to config endpoint when no other source", function()
		local orig_isdir = vim.fn.isdirectory
		local orig_filereadable = vim.fn.filereadable
		local orig_fnamemodify = vim.fn.fnamemodify

		vim.fn.isdirectory = function(path)
			if path == "/myproject/.mdemg" then
				return 1
			end
			return 0
		end
		vim.fn.filereadable = function()
			return 0
		end
		vim.fn.fnamemodify = function(path, mod)
			if mod == ":p:h" then
				return "/myproject"
			end
			if mod == ":h" then
				if path == "/myproject" then
					return "/"
				end
				return orig_fnamemodify(path, mod)
			end
			return orig_fnamemodify(path, mod)
		end

		local result = instance.resolve("/myproject/file.lua")

		vim.fn.isdirectory = orig_isdir
		vim.fn.filereadable = orig_filereadable
		vim.fn.fnamemodify = orig_fnamemodify

		assert.is_not_nil(result)
		assert.equals("http://localhost:9999", result.endpoint)
		assert.equals("/myproject", result.project_root)
	end)
end)
