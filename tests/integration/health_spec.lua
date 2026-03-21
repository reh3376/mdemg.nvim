-- Integration tests: require MDEMG server running + MDEMG_INTEGRATION=1
-- Run: make test-integration
if not vim.env.MDEMG_INTEGRATION then
	return
end

describe("integration: health endpoints", function()
	local health

	before_each(function()
		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })
		health = require("mdemg.api.health")
		vim.g.mdemg_space_id = "mdemg-dev"
		vim.b.mdemg_space_id = "mdemg-dev"
	end)

	-- IT-2: readyz
	it("readyz returns 200", function()
		local done = false
		local status_result
		health.readyz(function(err, status)
			status_result = status
			done = true
		end)
		vim.wait(5000, function()
			return done
		end)
		assert.equals(200, status_result)
	end)

	-- IT-2: stats
	it("stats returns valid data", function()
		local done = false
		local data_result
		health.stats(function(err, data)
			data_result = data
			done = true
		end)
		vim.wait(5000, function()
			return done
		end)
		assert.is_not_nil(data_result)
	end)

	-- IT-2: embedding_health
	it("embedding_health returns data", function()
		local done = false
		local data_result
		health.embedding_health(function(err, data)
			data_result = data
			done = true
		end)
		vim.wait(5000, function()
			return done
		end)
		assert.is_not_nil(data_result)
	end)

	-- IT-2: freshness
	it("freshness returns data for mdemg-dev", function()
		local done = false
		local data_result
		health.freshness("mdemg-dev", function(err, data)
			data_result = data
			done = true
		end)
		vim.wait(5000, function()
			return done
		end)
		assert.is_not_nil(data_result)
	end)
end)
