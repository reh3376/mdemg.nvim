describe("mdemg.api.spaces", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.spaces"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		vim.b.mdemg_endpoint = "http://localhost:9999"

		package.loaded["mdemg.client"] = {
			resolve_space_id = function() return "test-space" end,
			resolve_endpoint = function() return "http://localhost:9999" end,
			post = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "POST"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			get = function(path, opts)
				captured_path = path
				captured_method = "GET"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			delete = function(path, opts)
				captured_path = path
				captured_method = "DELETE"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			patch = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "PATCH"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			request = function(method, path, opts)
				captured_path = path
				captured_method = method
				captured_body = opts.body
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		mod = require("mdemg.api.spaces")
	end)

	describe("list", function()
		it("calls correct endpoint", function()
			mod.list(function() end)
			assert.equals("/v1/admin/spaces", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("update", function()
		it("calls PATCH with space_id in path", function()
			mod.update("my-space", { prunable = true }, function() end)
			assert.equals("/v1/admin/spaces/my-space", captured_path)
			assert.equals("PATCH", captured_method)
		end)

		it("passes prunable and protected in body", function()
			mod.update("my-space", { prunable = false, protected = true }, function() end)
			assert.is_false(captured_body.prunable)
			assert.is_true(captured_body.protected)
		end)
	end)

	describe("export", function()
		it("calls correct endpoint", function()
			mod.export({ profile = "shareable" }, function() end)
			assert.equals("/v1/admin/spaces/export", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes profile and obs_types in body", function()
			mod.export({ profile = "full", obs_types = { "learning", "decision" } }, function() end)
			assert.equals("full", captured_body.profile)
			assert.same({ "learning", "decision" }, captured_body.obs_types)
		end)
	end)

	describe("import", function()
		it("calls correct endpoint", function()
			mod.import({ target_space = "dest" }, function() end)
			assert.equals("/v1/admin/spaces/import", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes target_space in body", function()
			mod.import({ target_space = "new-space" }, function() end)
			assert.equals("new-space", captured_body.target_space)
		end)
	end)

	describe("prune", function()
		it("calls correct endpoint", function()
			mod.prune({ dry_run = true }, function() end)
			assert.equals("/v1/admin/spaces/prune", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes dry_run in body", function()
			mod.prune({ dry_run = true }, function() end)
			assert.is_true(captured_body.dry_run)
		end)
	end)

	describe("freshness_batch", function()
		it("uses client.request with GET method", function()
			mod.freshness_batch({ "space-a", "space-b" }, function() end)
			assert.equals("GET", captured_method)
		end)

		it("builds query string with space_ids[] params", function()
			mod.freshness_batch({ "alpha", "beta" }, function() end)
			assert.truthy(captured_path:find("/v1/memory/freshness%?"))
			assert.truthy(captured_path:find("space_ids%[%]=alpha"))
			assert.truthy(captured_path:find("space_ids%[%]=beta"))
		end)
	end)
end)
