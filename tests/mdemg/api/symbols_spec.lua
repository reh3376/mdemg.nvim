describe("mdemg.api.symbols", function()
	local mod
	local captured_path, captured_opts

	before_each(function()
		package.loaded["mdemg.api.symbols"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		vim.b.mdemg_space_id = "test-space"
		vim.g.mdemg_space_id = nil

		package.loaded["mdemg.client"] = {
			resolve_space_id = function()
				return "test-space"
			end,
			resolve_endpoint = function()
				return "http://localhost:9999"
			end,
			post = function(path, body, opts)
				captured_path = path
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			get = function(path, opts)
				captured_path = path
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			delete = function(path, opts)
				captured_path = path
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			patch = function(path, body, opts)
				captured_path = path
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			request = function(method, path, opts)
				captured_path = path
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		mod = require("mdemg.api.symbols")
	end)

	describe("search", function()
		it("calls correct endpoint", function()
			mod.search("MyFunction", {}, function() end)
			assert.equals("/v1/memory/symbols", captured_path)
		end)

		it("passes query in params", function()
			mod.search("HandleRequest", {}, function() end)
			assert.equals("HandleRequest", captured_opts.params.query)
		end)

		it("includes space_id from vim.b", function()
			mod.search("test", {}, function() end)
			assert.equals("test-space", captured_opts.params.space_id)
		end)

		it("passes type filter in params", function()
			mod.search("Serve", { type = "function" }, function() end)
			assert.equals("function", captured_opts.params.type)
		end)

		it("converts limit to string", function()
			mod.search("test", { limit = 20 }, function() end)
			assert.equals("20", captured_opts.params.limit)
		end)
	end)
end)
