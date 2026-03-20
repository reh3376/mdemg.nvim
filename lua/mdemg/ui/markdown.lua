local M = {}

function M.render(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	vim.bo[bufnr].filetype = "markdown"
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].swapfile = false

	local win = vim.fn.bufwinid(bufnr)
	if win ~= -1 then
		vim.wo[win].conceallevel = 2
		vim.wo[win].concealcursor = "nc"
	end

	pcall(vim.treesitter.start, bufnr, "markdown")
end

function M.format_results(results)
	local lines = {}
	for i, result in ipairs(results) do
		table.insert(lines, "## " .. (result.name or result.node_id or "Result " .. i))
		if result.score then
			table.insert(lines, string.format("**Score:** %.3f", result.score))
		end
		if result.path then
			table.insert(lines, "**Path:** `" .. result.path .. "`")
		end
		if result.layer then
			table.insert(lines, "**Layer:** " .. result.layer)
		end
		if result.summary then
			table.insert(lines, "")
			table.insert(lines, result.summary)
		end
		if result.evidence and #result.evidence > 0 then
			table.insert(lines, "")
			table.insert(lines, "### Evidence")
			for _, ev in ipairs(result.evidence) do
				local loc = ev.file_path or ev.file or ""
				if ev.line then
					loc = loc .. ":" .. ev.line
				end
				table.insert(
					lines,
					"- `" .. (ev.symbol_name or "?") .. "` (" .. (ev.symbol_type or "?") .. ") at `" .. loc .. "`"
				)
			end
		end
		table.insert(lines, "")
		table.insert(lines, "---")
		table.insert(lines, "")
	end
	return lines
end

function M.format_detail(result)
	local lines = {}
	table.insert(lines, "# " .. (result.name or result.node_id or "Memory Node"))
	table.insert(lines, "")
	if result.node_id then
		table.insert(lines, "**Node ID:** `" .. result.node_id .. "`")
	end
	if result.score then
		table.insert(lines, string.format("**Score:** %.3f", result.score))
	end
	if result.path then
		table.insert(lines, "**Path:** `" .. result.path .. "`")
	end
	if result.layer then
		table.insert(lines, "**Layer:** " .. result.layer)
	end
	if result.confidence_level then
		table.insert(lines, "**Confidence:** " .. result.confidence_level)
	end
	table.insert(lines, "")
	if result.summary then
		table.insert(lines, "## Summary")
		table.insert(lines, "")
		table.insert(lines, result.summary)
		table.insert(lines, "")
	end
	if result.jiminy then
		table.insert(lines, "## Retrieval Details")
		table.insert(lines, "")
		if result.jiminy.rationale then
			table.insert(lines, result.jiminy.rationale)
		end
		table.insert(lines, "")
	end
	if result.evidence and #result.evidence > 0 then
		table.insert(lines, "## Evidence")
		table.insert(lines, "")
		for _, ev in ipairs(result.evidence) do
			table.insert(lines, "### `" .. (ev.symbol_name or "unknown") .. "`")
			table.insert(lines, "- Type: " .. (ev.symbol_type or "unknown"))
			local loc = ev.file_path or ev.file or ""
			if ev.line then
				loc = loc .. ":" .. ev.line
			end
			if ev.line_end then
				loc = loc .. "-" .. ev.line_end
			end
			table.insert(lines, "- Location: `" .. loc .. "`")
			if ev.signature then
				table.insert(lines, "- Signature: `" .. ev.signature .. "`")
			end
			table.insert(lines, "")
		end
	end
	return lines
end

return M
