describe("mdemg.api.constraints", function()
	local constraints
	local captured_path, captured_method

	before_each(function()
		package.loaded["mdemg.api.constraints"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		package.loaded["mdemg.client"] = {
			post = function(path, _, opts)
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
					opts.on_success(200, { constraints = {} })
				end
			end,
		}

		constraints = require("mdemg.api.constraints")
	end)

	describe("list", function()
		it("calls correct endpoint", function()
			constraints.list(function() end)
			assert.equals("/v1/constraints", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("stats", function()
		it("calls correct endpoint", function()
			constraints.stats(function() end)
			assert.equals("/v1/constraints/stats", captured_path)
		end)
	end)

	describe("effectiveness", function()
		it("calls correct endpoint with id", function()
			constraints.effectiveness("c-123", function() end)
			assert.equals("/v1/constraints/effectiveness", captured_path)
		end)

		it("calls without id", function()
			constraints.effectiveness(nil, function() end)
			assert.equals("/v1/constraints/effectiveness", captured_path)
		end)
	end)

	describe("conflicts", function()
		it("calls correct endpoint", function()
			constraints.conflicts(function() end)
			assert.equals("/v1/constraints/conflicts", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("detect_conflicts", function()
		it("calls correct endpoint", function()
			constraints.detect_conflicts(nil, function() end)
			assert.equals("/v1/constraints/detect-conflicts", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)
end)
