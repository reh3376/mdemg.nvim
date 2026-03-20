local M = {}

M._active = nil

function M.run()
	local notify = require("mdemg.ui.notify")
	local api = require("mdemg.api.jiminy")
	local float = require("mdemg.ui.float")
	local cfg = require("mdemg.config").get()

	if M._active then
		float.close(M._active)
		M._active = nil
	end

	local filepath = vim.fn.expand("%:p")
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]
	local total = vim.api.nvim_buf_line_count(0)
	local start_line = math.max(0, row - 51)
	local end_line = math.min(total, row + 50)
	local context_lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
	local context = table.concat(context_lines, "\n")

	local ok_ts, ts = pcall(require, "mdemg.util.treesitter")
	if ok_ts then
		local ts_ctx = ts.get_context()
		if ts_ctx.function_name then
			context = "Current function: " .. ts_ctx.function_name .. "\n\n" .. context
		end
	end

	api.guide(context, {
		file_path = filepath ~= "" and vim.fn.fnamemodify(filepath, ":.") or nil,
	}, function(err, data)
		if err then
			notify.error("Guidance failed: " .. err)
			return
		end
		if not data then
			notify.warn("No guidance returned")
			return
		end

		local lines = { "# Jiminy Guidance", "" }

		if data.constraints and #data.constraints > 0 then
			table.insert(lines, "## Constraints")
			for _, c in ipairs(data.constraints) do
				local prefix = c.type == "must" and "[MUST]" or "[SHOULD]"
				table.insert(lines, prefix .. " **" .. (c.name or "?") .. "**")
				if c.description then
					table.insert(lines, "  " .. c.description)
				end
			end
			table.insert(lines, "")
		end

		if data.corrections and #data.corrections > 0 then
			table.insert(lines, "## Corrections")
			for _, c in ipairs(data.corrections) do
				table.insert(lines, "- **Issue:** " .. (c.issue or "?"))
				if c.suggestion then
					table.insert(lines, "  **Fix:** " .. c.suggestion)
				end
			end
			table.insert(lines, "")
		end

		if data.suggestions and #data.suggestions > 0 then
			table.insert(lines, "## Suggestions")
			for _, s in ipairs(data.suggestions) do
				table.insert(lines, "- " .. (s.text or "?"))
			end
		end

		if #lines <= 2 then
			table.insert(lines, "No guidance for current context.")
		end

		M._active = float.open({
			title = "Jiminy",
			content = lines,
			filetype = "markdown",
			modifiable = false,
			anchor = "NE",
			on_close = function()
				M._active = nil
			end,
			keymaps = {
				["+"] = function()
					if data.guidance_id then
						api.feedback(data.guidance_id, true, { applied = true }, function() end)
						notify.info("Guidance marked helpful")
					end
				end,
				["-"] = function()
					if data.guidance_id then
						api.feedback(data.guidance_id, false, {}, function() end)
						notify.info("Guidance marked unhelpful")
					end
				end,
			},
		})

		local timeout = cfg.ui.float_timeout or 10
		if timeout > 0 then
			vim.defer_fn(function()
				if M._active then
					float.close(M._active)
					M._active = nil
				end
			end, timeout * 1000)
		end
	end)
end

return M
