describe("mdemg.api.learning", function()
	local learning
	local captured_path, captured_body, captured_method

	before_each(function()
		package.loaded["mdemg.api.learning"] = nil
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
					opts.on_success(200, {})
				end
			end,
		}

		learning = require("mdemg.api.learning")
	end)

	describe("freeze", function()
		it("calls correct endpoint", function()
			learning.freeze("test reason", function() end)
			assert.equals("/v1/learning/freeze", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes reason", function()
			learning.freeze("stable scoring", function() end)
			assert.equals("stable scoring", captured_body.reason)
		end)
	end)

	describe("unfreeze", function()
		it("calls correct endpoint", function()
			learning.unfreeze(function() end)
			assert.equals("/v1/learning/unfreeze", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)

	describe("freeze_status", function()
		it("calls correct endpoint", function()
			learning.freeze_status(function() end)
			assert.equals("/v1/learning/freeze/status", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("prune", function()
		it("calls correct endpoint", function()
			learning.prune({}, function() end)
			assert.equals("/v1/learning/prune", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes dry_run option", function()
			learning.prune({ dry_run = true }, function() end)
			assert.is_true(captured_body.dry_run)
		end)
	end)

	describe("stats", function()
		it("calls correct endpoint", function()
			learning.stats(function() end)
			assert.equals("/v1/learning/stats", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("distribution", function()
		it("calls correct endpoint", function()
			learning.distribution(function() end)
			assert.equals("/v1/memory/distribution", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("frontiers", function()
		it("calls correct endpoint", function()
			learning.frontiers({}, function() end)
			assert.equals("/v1/memory/frontiers", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)
end)
