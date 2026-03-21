describe("mdemg.api.admin", function()
	local admin
	local captured_path, captured_body, captured_method

	before_each(function()
		package.loaded["mdemg.api.admin"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		package.loaded["mdemg.client"] = {
			resolve_space_id = function() return "test-space" end,
			resolve_endpoint = function() return "http://localhost:9999" end,
			post = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "POST"
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			get = function(path, opts)
				captured_path = path
				captured_method = "GET"
				if opts.on_success then
					opts.on_success(200, { spaces = {} })
				end
			end,
			patch = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "PATCH"
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			delete = function(path, opts)
				captured_path = path
				captured_method = "DELETE"
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		admin = require("mdemg.api.admin")
	end)

	describe("list_spaces", function()
		it("calls correct endpoint", function()
			admin.list_spaces(function() end)
			assert.equals("/v1/admin/spaces", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("get_space", function()
		it("includes space_id in path", function()
			admin.get_space("my-space", function() end)
			assert.equals("/v1/admin/spaces/my-space", captured_path)
		end)
	end)

	describe("update_space", function()
		it("calls PATCH with body", function()
			admin.update_space("test", { prunable = true }, function() end)
			assert.equals("/v1/admin/spaces/test", captured_path)
			assert.equals("PATCH", captured_method)
			assert.is_true(captured_body.prunable)
		end)
	end)

	describe("delete_space", function()
		it("calls DELETE", function()
			admin.delete_space("old-space", function() end)
			assert.equals("/v1/admin/spaces/old-space", captured_path)
			assert.equals("DELETE", captured_method)
		end)
	end)

	describe("prune_spaces", function()
		it("calls correct endpoint", function()
			admin.prune_spaces({ dry_run = true }, function() end)
			assert.equals("/v1/admin/spaces/prune", captured_path)
			assert.equals("POST", captured_method)
			assert.is_true(captured_body.dry_run)
		end)
	end)

	describe("export", function()
		it("calls correct endpoint with space_id and profile", function()
			admin.export({ space_id = "test", profile = "shareable" }, function() end)
			assert.equals("/v1/admin/spaces/export", captured_path)
			assert.equals("test", captured_body.space_id)
			assert.equals("shareable", captured_body.profile)
		end)
	end)

	describe("meta_learn", function()
		it("calls correct endpoint", function()
			admin.meta_learn({ space_id = "test" }, function() end)
			assert.equals("/v1/memory/meta-learn", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)
end)
