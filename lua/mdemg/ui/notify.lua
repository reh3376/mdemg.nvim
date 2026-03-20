local M = {}

local function get_notify()
	local cfg = require("mdemg.config").get()
	if cfg.ui.use_notify then
		local ok, notify = pcall(require, "notify")
		if ok then
			return notify
		end
	end
	return vim.notify
end

function M.info(msg)
	get_notify()(msg, vim.log.levels.INFO, { title = "MDEMG" })
end

function M.warn(msg)
	get_notify()(msg, vim.log.levels.WARN, { title = "MDEMG" })
end

function M.error(msg)
	get_notify()(msg, vim.log.levels.ERROR, { title = "MDEMG" })
end

function M.debug(msg)
	local cfg = require("mdemg.config").get()
	if cfg.log_level == "debug" then
		get_notify()(msg, vim.log.levels.DEBUG, { title = "MDEMG" })
	end
end

return M
