describe("mdemg.api.skills", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.skills"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		vim.b.mdemg_space_id = "test-space"
		vim.g.mdemg_session_id = "test-session"

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

		mod = require("mdemg.api.skills")
	end)

	describe("list", function()
		it("calls correct endpoint", function()
			mod.list(function() end)
			assert.equals("/v1/skills", captured_path)
			assert.equals("GET", captured_method)
		end)

		it("passes space_id in params", function()
			mod.list(function() end)
			assert.equals("test-space", captured_opts.params.space_id)
		end)
	end)

	describe("register", function()
		it("calls correct endpoint with name interpolation", function()
			mod.register("my-skill", {}, function() end)
			assert.equals("/v1/skills/my-skill/register", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes description and sections in body", function()
			local sections = { { title = "s1", content = "c1" } }
			mod.register("test-skill", { description = "A skill", sections = sections }, function() end)
			assert.equals("A skill", captured_body.description)
			assert.same(sections, captured_body.sections)
		end)

		it("includes session_id from vim.g", function()
			mod.register("test-skill", {}, function() end)
			assert.equals("test-session", captured_body.session_id)
		end)
	end)

	describe("recall", function()
		it("calls correct endpoint with name interpolation", function()
			mod.recall("my-skill", function() end)
			assert.equals("/v1/skills/my-skill/recall", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("sends empty body", function()
			mod.recall("my-skill", function() end)
			assert.same({}, captured_body)
		end)
	end)
end)
