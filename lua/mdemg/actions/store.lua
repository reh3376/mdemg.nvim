local M = {}

function M.run(opts)
	opts = opts or {}
	local float = require("mdemg.ui.float")

	local content = nil

	if opts.visual then
		vim.cmd('normal! "vy')
		content = vim.fn.getreg("v")
	end

	if content and content ~= "" then
		M._confirm_and_store(content)
	else
		local state
		state = float.open({
			title = "Store Observation",
			content = {
				"# Enter observation content",
				"# Lines starting with # are comments",
				"# Press <C-s> to save, q to cancel",
				"",
			},
			modifiable = true,
			width = 80,
			height = 15,
			keymaps = {
				["<C-s>"] = function()
					local lines = vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)
					local filtered = {}
					for _, line in ipairs(lines) do
						if not line:match("^#") then
							table.insert(filtered, line)
						end
					end
					local text = vim.trim(table.concat(filtered, "\n"))
					if text ~= "" then
						float.close(state)
						M._confirm_and_store(text)
					else
						require("mdemg.ui.notify").warn("Nothing to store")
					end
				end,
			},
		})
	end
end

function M._confirm_and_store(content)
	local notify = require("mdemg.ui.notify")
	local api = require("mdemg.api.memory")
	local ts = require("mdemg.util.treesitter")

	local filepath = vim.fn.expand("%:p")
	local tags = ts.auto_tags()
	table.insert(tags, "source:neovim")

	local metadata = {
		source = "neovim-observation",
		tags = tags,
		path = filepath ~= "" and vim.fn.fnamemodify(filepath, ":.") or nil,
		sensitivity = "internal",
	}

	api.ingest(content, metadata, function(err, data)
		if err then
			notify.error("Store failed: " .. err)
			return
		end
		local msg = "Stored"
		if data and data.node_id then
			msg = msg .. " (" .. data.node_id .. ")"
		end
		if data and data.anomalies and #data.anomalies > 0 then
			for _, a in ipairs(data.anomalies) do
				msg = msg .. "\n! " .. (a.message or a.type)
			end
		end
		notify.info(msg)
	end)
end

return M
