local M = {}

local subcommands = { "trigger" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgWebhooks:" }, function(choice)
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
	local api = require("mdemg.api.webhooks")

	if sub == "trigger" then
		local source = args and args[2]
		if not source then
			notify.warn("Usage: MdemgWebhooks trigger <source>")
			return
		end
		api.trigger(source, {}, function(err, data)
			if err then
				notify.error(err)
			else
				notify.info("Webhook triggered: " .. (data.status or "OK"))
			end
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
