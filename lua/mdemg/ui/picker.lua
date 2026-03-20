local M = {}

function M.pick(items, opts)
	opts = opts or {}
	local cfg = require("mdemg.config").get()

	if cfg.ui.use_telescope then
		local ok = pcall(require, "telescope")
		if ok then
			M._telescope_pick(items, opts)
			return
		end
	end

	M._fallback_pick(items, opts)
end

function M._telescope_pick(items, opts)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	local format_item = opts.format_item or tostring

	local previewer = nil
	if opts.preview then
		previewer = previewers.new_buffer_previewer({
			title = "Preview",
			define_preview = function(self, entry)
				local preview_lines = opts.preview(entry.value)
				if type(preview_lines) == "string" then
					preview_lines = vim.split(preview_lines, "\n")
				end
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
				vim.bo[self.state.bufnr].filetype = "markdown"
			end,
		})
	end

	pickers
		.new({}, {
			prompt_title = opts.prompt or "MDEMG",
			finder = finders.new_table({
				results = items,
				entry_maker = function(item)
					local display = format_item(item)
					return {
						value = item,
						display = display,
						ordinal = display,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewer,
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and opts.on_select then
						opts.on_select(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

function M._fallback_pick(items, opts)
	local format_item = opts.format_item or tostring
	vim.ui.select(items, {
		prompt = opts.prompt or "MDEMG",
		format_item = format_item,
	}, function(item)
		if item and opts.on_select then
			opts.on_select(item)
		end
	end)
end

return M
