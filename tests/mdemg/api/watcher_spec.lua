describe("mdemg.api.watcher", function()
	local watcher
	local captured_path, captured_body, captured_method

	before_each(function()
		package.loaded["mdemg.api.watcher"] = nil
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
					opts.on_success(200, { status = "watching" })
				end
			end,
			get = function(path, opts)
				captured_path = path
				captured_method = "GET"
				if opts.on_success then
					opts.on_success(200, { watchers = {}, count = 0 })
				end
			end,
		}

		watcher = require("mdemg.api.watcher")
	end)

	describe("start", function()
		it("calls correct endpoint", function()
			watcher.start({ space_id = "test", path = "/src" }, function() end)
			assert.equals("/v1/filewatcher/start", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes space_id and path", function()
			watcher.start({ space_id = "my-space", path = "/project" }, function() end)
			assert.equals("my-space", captured_body.space_id)
			assert.equals("/project", captured_body.path)
		end)
	end)

	describe("status", function()
		it("calls correct endpoint", function()
			watcher.status(function() end)
			assert.equals("/v1/filewatcher/status", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("stop", function()
		it("calls correct endpoint", function()
			watcher.stop(function() end)
			assert.equals("/v1/filewatcher/stop", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)
end)
