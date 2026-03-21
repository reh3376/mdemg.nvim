-- Integration tests: require MDEMG server running + MDEMG_INTEGRATION=1
-- Run: make test-integration
if not vim.env.MDEMG_INTEGRATION then
	return
end

describe("integration: client health tracking", function()
	before_each(function()
		package.loaded["mdemg.client"] = nil
		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })
	end)

	-- IT-8: health tracking with valid endpoint
	it("marks endpoint healthy after successful request", function()
		local client = require("mdemg.client")
		local done = false
		client.get("/readyz", {
			on_success = function()
				done = true
			end,
			on_error = function()
				done = true
			end,
		})
		vim.wait(5000, function()
			return done
		end)
		assert.is_true(client.is_healthy("http://localhost:9999"))
	end)

	-- IT-8: health tracking with invalid endpoint
	it("marks endpoint unhealthy after failures", function()
		local client = require("mdemg.client")
		-- Override endpoint to a dead port
		vim.b.mdemg_endpoint = "http://localhost:19999"

		local fail_count = 0
		for _ = 1, 3 do
			local done = false
			client.get("/readyz", {
				endpoint = "http://localhost:19999",
				timeout = 2,
				on_success = function()
					done = true
				end,
				on_error = function()
					fail_count = fail_count + 1
					done = true
				end,
			})
			vim.wait(5000, function()
				return done
			end)
		end

		assert.equals(3, fail_count)
		assert.is_false(client.is_healthy("http://localhost:19999"))

		-- Cleanup
		vim.b.mdemg_endpoint = nil
	end)
end)
