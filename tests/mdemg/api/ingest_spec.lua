describe("mdemg.api.ingest", function()
	local ingest
	local captured_path, captured_body, captured_method

	before_each(function()
		package.loaded["mdemg.api.ingest"] = nil
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
					opts.on_success(200, { job_id = "test-123" })
				end
			end,
			get = function(path, opts)
				captured_path = path
				captured_method = "GET"
				if opts.on_success then
					opts.on_success(200, { jobs = {} })
				end
			end,
		}

		ingest = require("mdemg.api.ingest")
	end)

	describe("trigger", function()
		it("calls correct endpoint", function()
			ingest.trigger(".", {}, function() end)
			assert.equals("/v1/memory/ingest/trigger", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes path in body", function()
			ingest.trigger("/src", {}, function() end)
			assert.equals("/src", captured_body.path)
		end)
	end)

	describe("status", function()
		it("calls correct endpoint with job_id", function()
			ingest.status("job-abc", function() end)
			assert.equals("/v1/memory/ingest/status/job-abc", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("cancel", function()
		it("calls correct endpoint", function()
			ingest.cancel("job-abc", function() end)
			assert.equals("/v1/memory/ingest/cancel/job-abc", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)

	describe("jobs", function()
		it("calls correct endpoint", function()
			ingest.jobs(function() end)
			assert.equals("/v1/memory/ingest/jobs", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("files", function()
		it("calls correct endpoint", function()
			ingest.files({ "/test/file.lua" }, function() end)
			assert.equals("/v1/memory/ingest/files", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)
end)
