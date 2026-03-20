local M = {}

local subcommands = { "start", "status", "stop" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgWatcher:" }, function(choice)
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
	local api = require("mdemg.api.watcher")
	local float = require("mdemg.ui.float")

	if sub == "start" then
		local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
		local path = args and args[2] or vim.fn.getcwd()
		api.start({ space_id = space_id, path = path }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			notify.info("File watcher started: " .. (data.status or "watching"))
		end)
	elseif sub == "status" then
		api.status(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "File Watcher Status",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "stop" then
		api.stop(function(err)
			if err then
				notify.error(err)
			else
				notify.info("File watcher stopped")
			end
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
