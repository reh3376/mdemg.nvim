local M = {}

M._state = {
	connected = false,
	space_id = nil,
	node_count = nil,
	health_score = nil,
	freshness = nil,
	embedding_provider = nil,
	last_check = nil,
}

function M.update_state(new_state)
	M._state = vim.tbl_extend("force", M._state, new_state)
end

function M.component()
	local cfg = require("mdemg.config").get()
	local s = M._state

	local icon
	if s.connected then
		icon = cfg.statusline.icons and "🧠" or "[M]"
	else
		icon = cfg.statusline.icons and "💀" or "[M!]"
	end

	if cfg.statusline.format == "long" then
		local parts = { icon }
		if s.space_id then
			table.insert(parts, s.space_id)
		end
		if s.node_count then
			table.insert(parts, tostring(s.node_count) .. "n")
		end
		if s.health_score then
			table.insert(parts, string.format("%.0f%%", s.health_score * 100))
		end
		return table.concat(parts, " ")
	end

	local parts = { icon }
	if s.space_id then
		table.insert(parts, s.space_id)
	end
	if s.node_count then
		table.insert(parts, tostring(s.node_count))
	end
	return table.concat(parts, " ")
end

function M.color()
	local s = M._state
	if not s.connected then
		return { fg = "#ff5555" }
	end
	if s.freshness and s.freshness.is_stale then
		return { fg = "#f1fa8c" }
	end
	return { fg = "#50fa7b" }
end

function M.show_status()
	local client = require("mdemg.client")
	local float = require("mdemg.ui.float")

	local endpoint = vim.b.mdemg_endpoint or vim.g.mdemg_endpoint or require("mdemg.config").get().endpoint
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id or "unknown"
	local session_id = vim.g.mdemg_session_id or "none"

	local plugin_version = require("mdemg")._VERSION or "unknown"

	local lines = {
		"# MDEMG Status",
		"",
		"**Plugin Version:** " .. plugin_version,
		"**Endpoint:** " .. endpoint,
		"**Space ID:** " .. space_id,
		"**Session ID:** " .. session_id,
		"**Connected:** " .. tostring(M._state.connected),
		"",
		"Loading details...",
	}

	local state = float.open({
		title = "MDEMG Status",
		content = lines,
		filetype = "markdown",
		modifiable = false,
		width = 60,
		height = 20,
	})

	client.get("/v1/memory/stats", {
		params = { space_id = space_id },
		on_success = function(_, data)
			if not data then
				return
			end
			local detail = {
				"# MDEMG Status",
				"",
				"**Plugin Version:** " .. plugin_version,
				"**Endpoint:** " .. endpoint,
				"**Space ID:** " .. space_id,
				"**Session ID:** " .. session_id,
				"**Connected:** true",
				"",
				"## Memory Stats",
				"**Total Nodes:** " .. (data.memory_count or "?"),
				"**Observations:** " .. (data.observation_count or "?"),
				"**Embedding Coverage:** " .. string.format("%.1f%%", (data.embedding_coverage or 0) * 100),
				"**Health Score:** " .. string.format("%.2f", data.health_score or 0),
				"",
			}
			if data.memories_by_layer then
				table.insert(detail, "## Layers")
				for layer, count in pairs(data.memories_by_layer) do
					table.insert(detail, "- L" .. layer .. ": " .. count)
				end
				table.insert(detail, "")
			end
			if data.learning_activity then
				table.insert(detail, "## Learning")
				table.insert(detail, "**Edges:** " .. (data.learning_activity.co_activated_edges or "?"))
				table.insert(
					detail,
					"**Avg Weight:** " .. string.format("%.3f", data.learning_activity.avg_weight or 0)
				)
				table.insert(detail, "")
			end
			if data.temporal_distribution then
				table.insert(detail, "## Activity")
				table.insert(detail, "**Last 24h:** " .. (data.temporal_distribution.last_24h or "?"))
				table.insert(detail, "**Last 7d:** " .. (data.temporal_distribution.last_7d or "?"))
				table.insert(detail, "**Last 30d:** " .. (data.temporal_distribution.last_30d or "?"))
			end
			float.update(state, detail)
		end,
		on_error = function(err)
			float.update(state, {
				"# MDEMG Status",
				"",
				"**Plugin Version:** " .. plugin_version,
				"**Endpoint:** " .. endpoint,
				"**Space ID:** " .. space_id,
				"**Session ID:** " .. session_id,
				"**Connected:** false",
				"",
				"**Error:** " .. err,
			})
		end,
	})
end

return M
