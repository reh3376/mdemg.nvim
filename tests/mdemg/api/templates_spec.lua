describe("mdemg.api.templates", function()
	local mod
	local captured_path, captured_body, captured_method

	before_each(function()
		package.loaded["mdemg.api.templates"] = nil
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
			patch = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "PATCH"
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			request = function(method, path, opts)
				captured_path = path
				captured_method = method
				captured_body = opts.body
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		mod = require("mdemg.api.templates")
	end)

	describe("list", function()
		it("calls correct endpoint with GET", function()
			mod.list(function() end)
			assert.equals("/v1/conversation/templates", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("create", function()
		it("calls correct endpoint with POST", function()
			mod.create({ name = "daily-standup" }, function() end)
			assert.equals("/v1/conversation/templates", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes body through", function()
			mod.create({ name = "retro", prompts = { "what went well" } }, function() end)
			assert.equals("retro", captured_body.name)
			assert.same({ "what went well" }, captured_body.prompts)
		end)
	end)

	describe("get", function()
		it("interpolates id into endpoint", function()
			mod.get("tmpl-42", function() end)
			assert.equals("/v1/conversation/templates/tmpl-42", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("update", function()
		it("uses PUT method via client.request", function()
			mod.update("tmpl-42", { name = "updated" }, function() end)
			assert.equals("/v1/conversation/templates/tmpl-42", captured_path)
			assert.equals("PUT", captured_method)
		end)

		it("passes body through", function()
			mod.update("tmpl-99", { name = "renamed", prompts = { "a", "b" } }, function() end)
			assert.equals("renamed", captured_body.name)
			assert.same({ "a", "b" }, captured_body.prompts)
		end)
	end)

	describe("delete", function()
		it("interpolates id and uses DELETE method", function()
			mod.delete("tmpl-old", function() end)
			assert.equals("/v1/conversation/templates/tmpl-old", captured_path)
			assert.equals("DELETE", captured_method)
		end)
	end)
end)
