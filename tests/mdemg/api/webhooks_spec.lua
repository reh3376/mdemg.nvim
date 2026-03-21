describe("mdemg.api.webhooks", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.webhooks"] = nil
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

		mod = require("mdemg.api.webhooks")
	end)

	describe("linear", function()
		it("calls correct endpoint", function()
			mod.linear({}, function() end)
			assert.equals("/v1/webhooks/linear", captured_path)
		end)

		it("passes body through", function()
			mod.linear({ action = "created", data = { id = "LIN-42" } }, function() end)
			assert.equals("created", captured_body.action)
			assert.equals("LIN-42", captured_body.data.id)
		end)
	end)

	describe("trigger", function()
		it("interpolates id into endpoint", function()
			mod.trigger("my-hook-id", {}, function() end)
			assert.equals("/v1/webhooks/my-hook-id", captured_path)
		end)

		it("passes body through", function()
			mod.trigger("wh-1", { event = "push" }, function() end)
			assert.equals("push", captured_body.event)
		end)
	end)
end)
