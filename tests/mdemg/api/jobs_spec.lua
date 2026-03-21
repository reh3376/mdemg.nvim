describe("mdemg.api.jobs", function()
	local mod
	local captured_path, captured_method

	before_each(function()
		package.loaded["mdemg.api.jobs"] = nil
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
				captured_method = "PATCH"
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			request = function(method, path, opts)
				captured_path = path
				captured_method = method
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		mod = require("mdemg.api.jobs")
	end)

	-- NOTE: stream() is intentionally not tested here.
	-- It uses vim.system directly for SSE streaming via curl,
	-- not the mdemg.client module, so it requires a vim.system mock.

	describe("status", function()
		it("interpolates job_id into endpoint", function()
			mod.status("job-abc-123", function() end)
			assert.equals("/v1/memory/ingest/status/job-abc-123", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("list", function()
		it("calls correct endpoint with GET", function()
			mod.list(function() end)
			assert.equals("/v1/memory/ingest/jobs", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)
end)
