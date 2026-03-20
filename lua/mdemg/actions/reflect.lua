local M = {}

function M.run(opts)
	opts = opts or {}
	local topic = opts.topic

	if opts.visual then
		vim.cmd('normal! "vy')
		topic = vim.fn.getreg("v")
	end

	if not topic or topic == "" then
		vim.ui.input({ prompt = "Reflect on: " }, function(input)
			if input and input ~= "" then
				M._execute(input, opts)
			end
		end)
		return
	end
	M._execute(topic, opts)
end

function M._execute(topic, opts)
	local notify = require("mdemg.ui.notify")
	local api = require("mdemg.api.memory")

	notify.info("Reflecting on: " .. topic)
	api.reflect(topic, {
		max_depth = opts.max_depth or 3,
		max_nodes = opts.max_nodes or 50,
	}, function(err, data)
		if err then
			notify.error("Reflection failed: " .. err)
			return
		end
		if not data then
			notify.warn("No reflection data")
			return
		end

		local lines = { "# Reflection: " .. topic, "" }

		if data.core_memories and #data.core_memories > 0 then
			table.insert(lines, "## Core Memories")
			table.insert(lines, "")
			for _, m in ipairs(data.core_memories) do
				table.insert(lines, "### " .. (m.name or m.node_id or "?"))
				if m.score then
					table.insert(lines, "**Score:** " .. string.format("%.3f", m.score))
				end
				if m.path then
					table.insert(lines, "**Path:** `" .. m.path .. "`")
				end
				if m.summary then
					table.insert(lines, "")
					table.insert(lines, m.summary)
				end
				table.insert(lines, "")
			end
		end

		if data.related_concepts and #data.related_concepts > 0 then
			table.insert(lines, "## Related Concepts")
			table.insert(lines, "")
			for _, c in ipairs(data.related_concepts) do
				table.insert(
					lines,
					"- **"
						.. (c.name or c.node_id or "?")
						.. "** (L"
						.. (c.layer or "?")
						.. ", score: "
						.. string.format("%.3f", c.score or 0)
						.. ")"
				)
			end
			table.insert(lines, "")
		end

		if data.abstractions and #data.abstractions > 0 then
			table.insert(lines, "## Abstractions")
			table.insert(lines, "")
			for _, a in ipairs(data.abstractions) do
				table.insert(lines, "- **" .. (a.name or a.node_id or "?") .. "** (L" .. (a.layer or "?") .. ")")
			end
			table.insert(lines, "")
		end

		if data.insights and #data.insights > 0 then
			table.insert(lines, "## Insights")
			table.insert(lines, "")
			for _, i in ipairs(data.insights) do
				table.insert(lines, "- " .. (i.description or "?"))
			end
			table.insert(lines, "")
		end

		if data.graph_context then
			table.insert(lines, "---")
			table.insert(
				lines,
				string.format(
					"*Explored %d nodes, %d edges, max layer %d*",
					data.graph_context.nodes_explored or 0,
					data.graph_context.edges_traversed or 0,
					data.graph_context.max_layer_reached or 0
				)
			)
		end

		vim.cmd("vnew")
		local buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].modifiable = false
		require("mdemg.ui.markdown").render(buf)
	end)
end

return M
