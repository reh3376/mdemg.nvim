describe("mdemg.api.plugins", function()
	local plugins
	local captured_path, captured_body, captured_method

	before_each(function()
		package.loaded["mdemg.api.plugins"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		package.loaded["mdemg.client"] = {
			resolve_space_id = function()
				return "test-space"
			end,
			resolve_endpoint = function()
				return "http://localhost:9999"
			end,
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
					opts.on_success(200, { plugins = {} })
				end
			end,
		}

		plugins = require("mdemg.api.plugins")
	end)

	describe("list", function()
		it("calls correct endpoint", function()
			plugins.list(function() end)
			assert.equals("/v1/plugins", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("get", function()
		it("includes id in path", function()
			plugins.get("my-plugin", function() end)
			assert.equals("/v1/plugins/my-plugin", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("create", function()
		it("calls correct endpoint", function()
			plugins.create({ name = "test", type = "INGESTION" }, function() end)
			assert.equals("/v1/plugins/create", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes name and type in body", function()
			plugins.create({ name = "my-plugin", type = "REASONING" }, function() end)
			assert.equals("my-plugin", captured_body.name)
			assert.equals("REASONING", captured_body.type)
		end)
	end)

	describe("validate", function()
		it("calls correct endpoint with id", function()
			plugins.validate("test-plugin", function() end)
			assert.equals("/v1/plugins/test-plugin/validate", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)

	describe("list_modules", function()
		it("calls correct endpoint", function()
			plugins.list_modules(function() end)
			assert.equals("/v1/modules", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("get_module", function()
		it("includes id in path", function()
			plugins.get_module("uxts-module", function() end)
			assert.equals("/v1/modules/uxts-module", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("ape_status", function()
		it("calls correct endpoint", function()
			plugins.ape_status(function() end)
			assert.equals("/v1/ape/status", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("ape_trigger", function()
		it("calls correct endpoint", function()
			plugins.ape_trigger({ event = "consolidate" }, function() end)
			assert.equals("/v1/ape/trigger", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes event in body", function()
			plugins.ape_trigger({ event = "consolidate" }, function() end)
			assert.equals("consolidate", captured_body.event)
		end)
	end)
end)
