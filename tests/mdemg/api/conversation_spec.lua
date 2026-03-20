describe("mdemg.api.conversation", function()
	local conv
	local captured_path, captured_body

	before_each(function()
		package.loaded["mdemg.api.conversation"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		package.loaded["mdemg.client"] = {
			post = function(path, body, opts)
				captured_path = path
				captured_body = body
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			get = function(path, opts)
				captured_path = path
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		conv = require("mdemg.api.conversation")
	end)

	describe("resume", function()
		it("calls correct endpoint", function()
			conv.resume("session-1", function() end)
			assert.equals("/v1/conversation/resume", captured_path)
		end)

		it("passes session_id", function()
			conv.resume("my-session", function() end)
			assert.equals("my-session", captured_body.session_id)
		end)
	end)

	describe("consolidate", function()
		it("calls correct endpoint", function()
			conv.consolidate("session-1", function() end)
			assert.equals("/v1/conversation/consolidate", captured_path)
		end)
	end)

	describe("observe", function()
		it("calls correct endpoint", function()
			conv.observe("something happened", "decision", function() end)
			assert.equals("/v1/conversation/observe", captured_path)
		end)

		it("passes content and obs_type", function()
			conv.observe("test content", "correction", function() end)
			assert.equals("test content", captured_body.content)
			assert.equals("correction", captured_body.obs_type)
		end)
	end)

	describe("correct", function()
		it("calls correct endpoint", function()
			conv.correct("wrong assumption", "right answer", function() end)
			assert.equals("/v1/conversation/correct", captured_path)
		end)
	end)

	describe("recall", function()
		it("calls correct endpoint", function()
			conv.recall("find this", {}, function() end)
			assert.equals("/v1/conversation/recall", captured_path)
		end)
	end)

	describe("volatile_stats", function()
		it("calls correct endpoint", function()
			conv.volatile_stats(function() end)
			assert.equals("/v1/conversation/volatile/stats", captured_path)
		end)
	end)

	describe("graduate", function()
		it("calls correct endpoint", function()
			conv.graduate({}, function() end)
			assert.equals("/v1/conversation/graduate", captured_path)
		end)
	end)
end)
