-- Integration tests: require MDEMG server running + MDEMG_INTEGRATION=1
-- Run: make test-integration
if not vim.env.MDEMG_INTEGRATION then
	return
end

describe("integration: conversation cycle", function()
	local conversation

	before_each(function()
		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })
		conversation = require("mdemg.api.conversation")
		vim.g.mdemg_space_id = "mdemg-dev"
		vim.b.mdemg_space_id = "mdemg-dev"
		vim.g.mdemg_session_id = "nvim-integration-test"
	end)

	-- IT-3: observe → recall
	it("observes and recalls conversation memory", function()
		local observe_done = false
		local observe_err
		conversation.observe("integration test observation " .. os.time(), {
			obs_type = "learning",
		}, function(err)
			observe_err = err
			observe_done = true
		end)
		vim.wait(5000, function()
			return observe_done
		end)
		assert.is_nil(observe_err)

		-- Brief pause for indexing
		vim.wait(500)

		local recall_done = false
		local recall_data
		conversation.recall({ max_observations = 5 }, function(err, data)
			recall_data = data
			recall_done = true
		end)
		vim.wait(5000, function()
			return recall_done
		end)
		assert.is_not_nil(recall_data)
	end)
end)
