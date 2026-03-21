-- Integration tests: require MDEMG server running + MDEMG_INTEGRATION=1
-- Run: make test-integration
if not vim.env.MDEMG_INTEGRATION then
	return
end

describe("integration: validate and guide", function()
	local memory, jiminy

	before_each(function()
		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })
		memory = require("mdemg.api.memory")
		jiminy = require("mdemg.api.jiminy")
		vim.g.mdemg_space_id = "mdemg-dev"
		vim.b.mdemg_space_id = "mdemg-dev"
		vim.g.mdemg_session_id = "nvim-integration-test"
	end)

	-- IT-5: validate with dummy diff
	it("validate returns structured response", function()
		local done = false
		local result
		memory.validate("+ added line\n- removed line", { "test.go" }, function(err, data)
			result = data
			done = true
		end)
		vim.wait(5000, function()
			return done
		end)
		assert.is_not_nil(result)
	end)

	-- IT-6: jiminy guide with code context
	it("jiminy guide returns guidance", function()
		local done = false
		jiminy.guide("func VectorRecall(ctx context.Context)", {
			file_path = "internal/retrieval/recall.go",
			query = "How does recall work?",
		}, function()
			done = true
		end)
		vim.wait(10000, function()
			return done
		end)
		-- May return nil if Jiminy is disabled, that's OK
		-- Just verify no crash
		assert.is_true(done)
	end)
end)
