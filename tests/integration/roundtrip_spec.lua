-- Integration tests: require MDEMG server running + MDEMG_INTEGRATION=1
-- Run: make test-integration
if not vim.env.MDEMG_INTEGRATION then
	return
end

describe("integration: round-trip", function()
	local api

	before_each(function()
		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })
		api = require("mdemg.api")
		vim.g.mdemg_space_id = "mdemg-dev"
		vim.b.mdemg_space_id = "mdemg-dev"
	end)

	-- IT-1: Store → Recall round-trip
	describe("store and recall", function()
		local stored_node_id

		it("stores an observation", function()
			local done = false
			local err_result
			api.memory.ingest("integration test observation: round-trip " .. os.time(), {
				source = "neovim-integration-test",
			}, function(err, data)
				err_result = err
				if data then
					stored_node_id = data.node_id
				end
				done = true
			end)
			vim.wait(5000, function()
				return done
			end)
			assert.is_nil(err_result)
			assert.is_not_nil(stored_node_id)
		end)

		it("recalls the stored observation", function()
			local done = false
			local results
			api.memory.retrieve("integration test round-trip", { top_k = 5 }, function(err, data)
				if data then
					results = data.results
				end
				done = true
			end)
			vim.wait(5000, function()
				return done
			end)
			assert.is_not_nil(results)
			assert.is_true(#results > 0)
		end)
	end)
end)
