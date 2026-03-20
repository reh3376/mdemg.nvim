local M = {}

M._timer = nil
M._pending = {}

function M.setup()
	local cfg = require("mdemg.config").get()
	if not cfg.auto.ingest_on_save then
		return
	end

	local group = vim.api.nvim_create_augroup("MdemgIngestOnSave", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function()
			local filepath = vim.fn.expand("%:p")
			if filepath == "" then
				return
			end

			local ext = vim.fn.fnamemodify(filepath, ":e")
			local watched = cfg.auto.ingest_extensions
			local found = false
			for _, e in ipairs(watched) do
				if ext == e then
					found = true
					break
				end
			end
			if not found then
				return
			end

			if not vim.b.mdemg_endpoint then
				return
			end

			M._pending[filepath] = true

			if M._timer then
				M._timer:stop()
			end
			M._timer = vim.defer_fn(function()
				M._flush()
			end, cfg.auto.ingest_debounce_ms)
		end,
	})
end

function M._flush()
	local paths = {}
	for path in pairs(M._pending) do
		table.insert(paths, path)
	end
	M._pending = {}

	if #paths == 0 then
		return
	end

	local api = require("mdemg.api.memory")
	local notify = require("mdemg.ui.notify")

	api.ingest_files(paths, function(err, data)
		if err then
			notify.error("Auto-ingest failed: " .. err)
			return
		end
		if data and data.error_count and data.error_count > 0 then
			notify.warn("Ingest: " .. data.error_count .. " errors")
		end
	end)
end

return M
