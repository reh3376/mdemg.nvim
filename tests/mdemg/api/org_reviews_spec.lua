describe("mdemg.api.org_reviews", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.org_reviews"] = nil
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

		mod = require("mdemg.api.org_reviews")
	end)

	describe("list", function()
		it("calls correct endpoint with GET", function()
			mod.list(function() end)
			assert.equals("/v1/conversation/org-reviews", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("stats", function()
		it("calls correct endpoint with GET", function()
			mod.stats(function() end)
			assert.equals("/v1/conversation/org-reviews/stats", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("decide", function()
		it("interpolates id and uses PATCH method", function()
			mod.decide("review-77", "approve", function() end)
			assert.equals("/v1/conversation/org-reviews/review-77/decide", captured_path)
			assert.equals("PATCH", captured_method)
		end)

		it("passes decision in body", function()
			mod.decide("review-88", "reject", function() end)
			assert.equals("reject", captured_body.decision)
		end)
	end)

	describe("flag", function()
		it("interpolates observation_id into endpoint", function()
			mod.flag("obs-123", "inaccurate", function() end)
			assert.equals("/v1/conversation/observations/obs-123/flag", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes reason in body", function()
			mod.flag("obs-456", "outdated information", function() end)
			assert.equals("outdated information", captured_body.reason)
		end)
	end)
end)
