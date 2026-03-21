describe("mdemg.api.scraper", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.scraper"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		vim.b.mdemg_space_id = "test-space"

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
		}

		mod = require("mdemg.api.scraper")
	end)

	describe("create", function()
		it("calls correct endpoint", function()
			mod.create({ "https://example.com" }, "my-space", function() end)
			assert.equals("/v1/scraper/jobs", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes urls and target_space_id in body", function()
			mod.create({ "https://a.com", "https://b.com" }, "target", function() end)
			assert.same({ "https://a.com", "https://b.com" }, captured_body.urls)
			assert.equals("target", captured_body.target_space_id)
		end)
	end)

	describe("list", function()
		it("calls correct endpoint", function()
			mod.list({}, function() end)
			assert.equals("/v1/scraper/jobs", captured_path)
			assert.equals("GET", captured_method)
		end)

		it("passes status filter in params", function()
			mod.list({ status = "running" }, function() end)
			assert.equals("running", captured_opts.params.status)
		end)

		it("resolves space_id from vim.b", function()
			mod.list({}, function() end)
			assert.equals("test-space", captured_opts.params.space_id)
		end)

		it("passes nil params when resolve_space_id returns nil", function()
			package.loaded["mdemg.client"].resolve_space_id = function()
				return nil
			end
			mod.list({}, function() end)
			assert.is_nil(captured_opts.params)
		end)
	end)

	describe("get", function()
		it("calls correct endpoint with job_id", function()
			mod.get("job-123", function() end)
			assert.equals("/v1/scraper/jobs/job-123", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("cancel", function()
		it("calls DELETE with job_id", function()
			mod.cancel("job-456", function() end)
			assert.equals("/v1/scraper/jobs/job-456", captured_path)
			assert.equals("DELETE", captured_method)
		end)
	end)

	describe("review", function()
		it("calls correct endpoint with job_id", function()
			mod.review("job-789", true, "looks good", function() end)
			assert.equals("/v1/scraper/jobs/job-789/review", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes reviewed and notes in body", function()
			mod.review("job-789", true, "approved", function() end)
			assert.is_true(captured_body.reviewed)
			assert.equals("approved", captured_body.notes)
		end)
	end)

	describe("spaces", function()
		it("calls correct endpoint", function()
			mod.spaces(function() end)
			assert.equals("/v1/scraper/spaces", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)
end)
