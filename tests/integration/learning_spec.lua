-- Integration tests: require MDEMG server running + MDEMG_INTEGRATION=1
-- Run: make test-integration
if not vim.env.MDEMG_INTEGRATION then
	return
end

describe("integration: learning lifecycle", function()
	local learning

	before_each(function()
		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })
		learning = require("mdemg.api.learning")
		vim.g.mdemg_space_id = "mdemg-dev"
		vim.b.mdemg_space_id = "mdemg-dev"
	end)

	-- IT-7: freeze → status → unfreeze → status
	it("freeze and unfreeze lifecycle", function()
		-- Freeze
		local freeze_done = false
		learning.freeze({ reason = "integration-test" }, function(err)
			freeze_done = true
		end)
		vim.wait(5000, function()
			return freeze_done
		end)
		assert.is_true(freeze_done)

		-- Check frozen status
		local status_done = false
		local freeze_status
		local health = require("mdemg.api.health")
		health.freeze_status(function(err, data)
			freeze_status = data
			status_done = true
		end)
		vim.wait(5000, function()
			return status_done
		end)
		assert.is_not_nil(freeze_status)

		-- Unfreeze
		local unfreeze_done = false
		learning.unfreeze(function(err)
			unfreeze_done = true
		end)
		vim.wait(5000, function()
			return unfreeze_done
		end)
		assert.is_true(unfreeze_done)
	end)
end)
