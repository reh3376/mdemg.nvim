describe("mdemg.api.rsic", function()
	local rsic
	local captured_path, captured_body, captured_method

	before_each(function()
		package.loaded["mdemg.api.rsic"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		package.loaded["mdemg.client"] = {
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

		rsic = require("mdemg.api.rsic")
	end)

	describe("cycle", function()
		it("calls correct endpoint", function()
			rsic.cycle({}, function() end)
			assert.equals("/v1/self-improve/cycle", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes dry_run option", function()
			rsic.cycle({ dry_run = true }, function() end)
			assert.is_true(captured_body.dry_run)
		end)
	end)

	describe("assess", function()
		it("calls correct endpoint", function()
			rsic.assess({}, function() end)
			assert.equals("/v1/self-improve/assess", captured_path)
		end)
	end)

	describe("report", function()
		it("calls correct endpoint", function()
			rsic.report(function() end)
			assert.equals("/v1/self-improve/report", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("report_detail", function()
		it("includes task_id in path", function()
			rsic.report_detail("task-42", function() end)
			assert.equals("/v1/self-improve/report/task-42", captured_path)
		end)
	end)

	describe("history", function()
		it("calls correct endpoint", function()
			rsic.history({}, function() end)
			assert.equals("/v1/self-improve/history", captured_path)
		end)
	end)

	describe("calibration", function()
		it("calls correct endpoint", function()
			rsic.calibration(function() end)
			assert.equals("/v1/self-improve/calibration", captured_path)
		end)
	end)

	describe("health", function()
		it("calls correct endpoint", function()
			rsic.health(function() end)
			assert.equals("/v1/self-improve/health", captured_path)
		end)
	end)

	describe("rollback", function()
		it("calls correct endpoint with cycle_id", function()
			rsic.rollback("cycle-99", function() end)
			assert.equals("/v1/self-improve/rollback", captured_path)
			assert.equals("POST", captured_method)
			assert.equals("cycle-99", captured_body.cycle_id)
		end)
	end)

	describe("reset", function()
		it("calls correct endpoint", function()
			rsic.reset({}, function() end)
			assert.equals("/v1/self-improve/orchestration/reset", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)
end)
