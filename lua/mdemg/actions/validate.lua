local M = {}

function M.run()
	local notify = require("mdemg.ui.notify")
	local api = require("mdemg.api.memory")
	local float = require("mdemg.ui.float")
	local diff_util = require("mdemg.util.diff")

	local diff = diff_util.buffer_diff()
	if not diff then
		notify.warn("No changes to validate")
		return
	end

	local files = diff_util.changed_files()
	if #files == 0 then
		local current = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
		if current ~= "" then
			files = { current }
		end
	end

	notify.info("Validating changes...")
	api.validate(diff, files, function(err, data)
		if err then
			notify.error("Validation failed: " .. err)
			return
		end
		if not data then
			notify.warn("No validation response")
			return
		end

		local lines = { "# Guardrail Validation", "" }

		local status = data.status or "Unknown"
		local status_icon
		if status == "Pass" then
			status_icon = "PASS"
		elseif status == "Warning" then
			status_icon = "WARN"
		else
			status_icon = "BLOCK"
		end
		table.insert(lines, "## Status: " .. status_icon .. " " .. status)
		table.insert(lines, "")

		if data.violations and #data.violations > 0 then
			table.insert(lines, "## Violations")
			table.insert(lines, "")
			for _, v in ipairs(data.violations) do
				table.insert(lines, "- **" .. (v.description or "Unknown") .. "**")
				if v.rationale then
					table.insert(lines, "  - " .. v.rationale)
				end
				if v.constraint_node_id then
					table.insert(lines, "  - Node: `" .. v.constraint_node_id .. "`")
				end
			end
			table.insert(lines, "")
		end

		if data.warnings and #data.warnings > 0 then
			table.insert(lines, "## Warnings")
			table.insert(lines, "")
			for _, w in ipairs(data.warnings) do
				table.insert(lines, "- **" .. (w.description or "Unknown") .. "**")
				if w.rationale then
					table.insert(lines, "  - " .. w.rationale)
				end
			end
		end

		if (not data.violations or #data.violations == 0) and (not data.warnings or #data.warnings == 0) then
			table.insert(lines, "No issues found.")
		end

		float.open({
			title = "Validation: " .. status,
			content = lines,
			filetype = "markdown",
			modifiable = false,
		})
	end)
end

return M
