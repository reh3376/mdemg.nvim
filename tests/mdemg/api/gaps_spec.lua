describe("mdemg.api.gaps", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.gaps"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		vim.b.mdemg_space_id = "test-space"
		vim.g.mdemg_space_id = nil

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

		mod = require("mdemg.api.gaps")
	end)

	describe("list", function()
		it("calls correct endpoint", function()
			mod.list(function() end)
			assert.equals("/v1/system/capability-gaps", captured_path)
		end)

		it("passes space_id when available", function()
			mod.list(function() end)
			assert.equals("test-space", captured_opts.params.space_id)
		end)

		it("omits params when resolve_space_id returns nil", function()
			package.loaded["mdemg.client"].resolve_space_id = function()
				return nil
			end
			mod.list(function() end)
			assert.is_nil(captured_opts.params)
		end)
	end)

	describe("get", function()
		it("calls correct endpoint with gap_id", function()
			mod.get("gap-42", function() end)
			assert.equals("/v1/system/capability-gaps/gap-42", captured_path)
		end)
	end)

	describe("interviews", function()
		it("calls correct endpoint", function()
			mod.interviews({}, function() end)
			assert.equals("/v1/system/gap-interviews", captured_path)
		end)

		it("converts limit to string in params", function()
			mod.interviews({ limit = 10 }, function() end)
			assert.equals("10", captured_opts.params.limit)
		end)

		it("omits params when no limit set", function()
			mod.interviews({}, function() end)
			assert.is_nil(captured_opts.params)
		end)
	end)

	describe("interview_detail", function()
		it("calls correct endpoint with interview_id", function()
			mod.interview_detail("iv-99", function() end)
			assert.equals("/v1/system/gap-interviews/iv-99", captured_path)
		end)
	end)

	describe("feedback", function()
		it("calls correct endpoint", function()
			mod.feedback("great work", nil, function() end)
			assert.equals("/v1/feedback", captured_path)
		end)

		it("passes content in body", function()
			mod.feedback("needs improvement", nil, function() end)
			assert.equals("needs improvement", captured_body.content)
		end)

		it("defaults obs_type to feedback", function()
			mod.feedback("content", nil, function() end)
			assert.equals("feedback", captured_body.obs_type)
		end)

		it("allows custom obs_type", function()
			mod.feedback("content", "correction", function() end)
			assert.equals("correction", captured_body.obs_type)
		end)
	end)
end)
