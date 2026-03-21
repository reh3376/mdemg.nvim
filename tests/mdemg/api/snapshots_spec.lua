describe("mdemg.api.snapshots", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.snapshots"] = nil
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

		mod = require("mdemg.api.snapshots")
	end)

	describe("list", function()
		it("calls correct endpoint with GET", function()
			mod.list(function() end)
			assert.equals("/v1/conversation/snapshot", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("create", function()
		it("calls correct endpoint with POST", function()
			mod.create({}, function() end)
			assert.equals("/v1/conversation/snapshot", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes opts as body", function()
			mod.create({ space_id = "test-space", label = "before-refactor" }, function() end)
			assert.equals("test-space", captured_body.space_id)
			assert.equals("before-refactor", captured_body.label)
		end)
	end)

	describe("get", function()
		it("interpolates id into endpoint", function()
			mod.get("snap-abc-123", function() end)
			assert.equals("/v1/conversation/snapshot/snap-abc-123", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("latest", function()
		it("calls correct endpoint with GET", function()
			mod.latest(function() end)
			assert.equals("/v1/conversation/snapshot/latest", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("delete", function()
		it("interpolates id and uses DELETE method", function()
			mod.delete("snap-xyz-789", function() end)
			assert.equals("/v1/conversation/snapshot/snap-xyz-789", captured_path)
			assert.equals("DELETE", captured_method)
		end)
	end)

	describe("cleanup", function()
		it("calls correct endpoint with POST", function()
			mod.cleanup(function() end)
			assert.equals("/v1/conversation/snapshot/cleanup", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)
end)
