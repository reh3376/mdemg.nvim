local M = {}

local subcommands = { "status" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgNeural:" }, function(choice)
			if choice then
				M._dispatch(choice, args)
			end
		end)
		return
	end
	M._dispatch(sub, args)
end

function M._dispatch(sub, args)
	local notify = require("mdemg.ui.notify")
	local api = require("mdemg.api.neural")
	local float = require("mdemg.ui.float")

	if sub == "status" then
		api.status(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local lines = { "# Neural Sidecar Status", "" }
			if data.status then
				table.insert(lines, "**Status:** " .. data.status)
			end
			if data.model then
				table.insert(lines, "**Model:** " .. data.model)
			end
			if data.provider then
				table.insert(lines, "**Provider:** " .. data.provider)
			end
			table.insert(lines, "")
			table.insert(lines, "## Raw Response")
			for _, l in ipairs(vim.split(vim.inspect(data), "\n")) do
				table.insert(lines, l)
			end
			float.open({ title = "Neural Status", content = lines, filetype = "markdown", modifiable = false })
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
