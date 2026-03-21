describe("mdemg.api.jiminy", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.jiminy"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

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

		mod = require("mdemg.api.jiminy")
	end)

	describe("guide", function()
		it("calls correct endpoint", function()
			mod.guide("some context", {}, function() end)
			assert.equals("/v1/jiminy/guide", captured_path)
		end)

		it("passes context in body", function()
			mod.guide("editing a buffer", {}, function() end)
			assert.equals("editing a buffer", captured_body.context)
		end)

		it("defaults max_items to 5", function()
			mod.guide("ctx", {}, function() end)
			assert.equals(5, captured_body.max_items)
		end)

		it("uses session_id from vim.g", function()
			mod.guide("ctx", {}, function() end)
			assert.equals("test-session", captured_body.session_id)
		end)

		it("unwraps data.data in callback", function()
			-- Override client to return nested data
			package.loaded["mdemg.client"].post = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "POST"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, { data = { items = { "a", "b" } } })
				end
			end
			local result
			mod.guide("ctx", {}, function(err, data)
				result = data
			end)
			assert.same({ items = { "a", "b" } }, result)
		end)
	end)

	describe("feedback", function()
		it("calls correct endpoint", function()
			mod.feedback("guid-123", true, {}, function() end)
			assert.equals("/v1/jiminy/feedback", captured_path)
		end)

		it("passes guidance_id and helpful in body", function()
			mod.feedback("guid-456", false, {}, function() end)
			assert.equals("guid-456", captured_body.guidance_id)
			assert.equals(false, captured_body.helpful)
		end)
	end)
end)
