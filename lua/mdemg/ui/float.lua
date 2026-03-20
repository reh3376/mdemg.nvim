local M = {}

function M.open(opts)
	opts = opts or {}
	local cfg = require("mdemg.config").get()

	local ui_width = vim.o.columns
	local ui_height = vim.o.lines
	local width = opts.width or math.floor(ui_width * (cfg.ui.width or 0.8))
	local height = opts.height or math.floor(ui_height * (cfg.ui.height or 0.8))
	local row = math.floor((ui_height - height) / 2)
	local col = math.floor((ui_width - width) / 2)

	if opts.anchor == "NE" then
		row = 1
		col = ui_width - width - 2
		width = math.min(width, math.floor(ui_width * 0.4))
		height = math.min(height, math.floor(ui_height * 0.4))
	end

	local buf = vim.api.nvim_create_buf(false, true)

	local lines = opts.content
	if type(lines) == "string" then
		lines = vim.split(lines, "\n")
	end
	lines = lines or {}
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = opts.border or cfg.ui.border or "rounded",
		title = opts.title and (" " .. opts.title .. " ") or nil,
		title_pos = opts.title and "center" or nil,
	}

	local win = vim.api.nvim_open_win(buf, opts.enter ~= false, win_opts)

	if opts.filetype then
		vim.bo[buf].filetype = opts.filetype
	end
	if opts.modifiable == false then
		vim.bo[buf].modifiable = false
		vim.bo[buf].readonly = true
	end
	vim.bo[buf].bufhidden = "wipe"
	vim.wo[win].wrap = true
	vim.wo[win].cursorline = true

	local state = { buf = buf, win = win }

	local close_fn = function()
		M.close(state)
		if opts.on_close then
			opts.on_close()
		end
	end
	vim.keymap.set("n", "q", close_fn, { buffer = buf, silent = true })
	vim.keymap.set("n", "<Esc>", close_fn, { buffer = buf, silent = true })

	vim.keymap.set("n", "y", function()
		local line = vim.api.nvim_get_current_line()
		vim.fn.setreg("+", line)
		require("mdemg.ui.notify").info("Copied to clipboard")
	end, { buffer = buf, silent = true })

	vim.keymap.set("n", "?", function()
		require("mdemg.ui.notify").info("q/Esc: close | y: yank line | r: refresh | CR: select")
	end, { buffer = buf, silent = true })

	if opts.keymaps then
		for key, fn in pairs(opts.keymaps) do
			vim.keymap.set("n", key, fn, { buffer = buf, silent = true })
		end
	end

	return state
end

function M.update(state, content)
	if not state or not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
		return
	end
	local lines = content
	if type(lines) == "string" then
		lines = vim.split(lines, "\n")
	end
	local was_modifiable = vim.bo[state.buf].modifiable
	vim.bo[state.buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
	vim.bo[state.buf].modifiable = was_modifiable
end

function M.close(state)
	if not state then
		return
	end
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
	end
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_buf_delete(state.buf, { force = true })
	end
end

return M
