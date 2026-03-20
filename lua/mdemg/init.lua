local M = {}

M._VERSION = "0.1.0"

function M.setup(opts)
	local config = require("mdemg.config")
	config.setup(opts or {})

	require("mdemg.auto.session").setup()
	require("mdemg.auto.health_poll").setup()
	require("mdemg.auto.ingest_on_save").setup()

	local instance = require("mdemg.util.instance")
	local space = require("mdemg.util.space")

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("MdemgInstance", { clear = true }),
		callback = function()
			local bufpath = vim.api.nvim_buf_get_name(0)
			if bufpath == "" then
				return
			end
			local info = instance.resolve(bufpath)
			if info then
				vim.b.mdemg_endpoint = info.endpoint
				vim.b.mdemg_space_id = space.resolve(info.project_root)
			end
		end,
	})

	local cfg = config.get()
	local keymaps = cfg.keymaps
	local actions = {
		recall = function()
			require("mdemg.actions.recall").run()
		end,
		store = function()
			require("mdemg.actions.store").run()
		end,
		validate = function()
			require("mdemg.actions.validate").run()
		end,
		guide = function()
			require("mdemg.actions.guide").run()
		end,
		reflect = function()
			require("mdemg.actions.reflect").run()
		end,
		symbols = function()
			require("mdemg.actions.recall").run({ symbols = true })
		end,
		status = function()
			require("mdemg.ui.statusline").show_status()
		end,
	}
	for name, lhs in pairs(keymaps) do
		if lhs and lhs ~= "" and actions[name] then
			vim.keymap.set("n", lhs, actions[name], { desc = "MDEMG: " .. name, silent = true })
		end
	end

	if keymaps.recall and keymaps.recall ~= "" then
		vim.keymap.set("v", keymaps.recall, function()
			require("mdemg.actions.recall").run({ visual = true })
		end, { desc = "MDEMG: recall selection", silent = true })
	end
	if keymaps.store and keymaps.store ~= "" then
		vim.keymap.set("v", keymaps.store, function()
			require("mdemg.actions.store").run({ visual = true })
		end, { desc = "MDEMG: store selection", silent = true })
	end
end

return M
