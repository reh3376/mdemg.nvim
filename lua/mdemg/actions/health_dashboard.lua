local M = {}

function M.run()
	local float = require("mdemg.ui.float")
	local health_api = require("mdemg.api.health")
	local rsic_api = require("mdemg.api.rsic")
	local learning_api = require("mdemg.api.learning")
	local neural_api = require("mdemg.api.neural")

	local lines = { "# MDEMG Health Dashboard", "", "Loading..." }
	local state = float.open({ title = "Health Dashboard", content = lines, filetype = "markdown", modifiable = false })
	if not state then
		return
	end

	local results = {}
	local pending = 5

	local function try_finish()
		pending = pending - 1
		if pending > 0 then
			return
		end
		local out = { "# MDEMG Health Dashboard", "" }

		-- Readyz
		if results.readyz then
			table.insert(out, "## Readiness")
			table.insert(out, string.format("**Status:** %s", results.readyz.status or "unknown"))
			table.insert(out, "")
		end

		-- Memory stats
		if results.stats then
			table.insert(out, "## Memory Stats")
			table.insert(out, string.format("**Total nodes:** %s", results.stats.total_nodes or "?"))
			table.insert(out, string.format("**Total edges:** %s", results.stats.total_edges or "?"))
			if results.stats.layers then
				table.insert(out, "")
				table.insert(out, "### Layers")
				for k, v in pairs(results.stats.layers or {}) do
					table.insert(out, string.format("- %s: %s", k, tostring(v)))
				end
			end
			table.insert(out, "")
		end

		-- RSIC health
		if results.rsic then
			table.insert(out, "## RSIC Health")
			for k, v in pairs(results.rsic) do
				table.insert(out, string.format("- **%s:** %s", k, tostring(v)))
			end
			table.insert(out, "")
		end

		-- Learning
		if results.learning then
			table.insert(out, "## Learning")
			for k, v in pairs(results.learning) do
				table.insert(out, string.format("- **%s:** %s", k, tostring(v)))
			end
			table.insert(out, "")
		end

		-- Neural
		if results.neural then
			table.insert(out, "## Neural Sidecar")
			for k, v in pairs(results.neural) do
				table.insert(out, string.format("- **%s:** %s", k, tostring(v)))
			end
			table.insert(out, "")
		end

		-- Errors
		if results.errors and #results.errors > 0 then
			table.insert(out, "## Errors")
			for _, e in ipairs(results.errors) do
				table.insert(out, "- " .. e)
			end
		end

		float.update(state, out)
	end

	results.errors = {}

	health_api.readyz(function(err, data)
		if err then
			table.insert(results.errors, "readyz: " .. err)
		else
			results.readyz = data
		end
		try_finish()
	end)

	health_api.stats(function(err, data)
		if err then
			table.insert(results.errors, "stats: " .. err)
		else
			results.stats = data
		end
		try_finish()
	end)

	rsic_api.health(function(err, data)
		if err then
			table.insert(results.errors, "rsic: " .. err)
		else
			results.rsic = data
		end
		try_finish()
	end)

	learning_api.stats(function(err, data)
		if err then
			table.insert(results.errors, "learning: " .. err)
		else
			results.learning = data
		end
		try_finish()
	end)

	neural_api.status(function(err, data)
		if err then
			table.insert(results.errors, "neural: " .. err)
		else
			results.neural = data
		end
		try_finish()
	end)
end

return M
