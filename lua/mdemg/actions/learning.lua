local M = {}

local subcommands = { "stats", "freeze", "unfreeze", "freeze-status", "prune", "distribution", "frontiers" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgLearning:" }, function(choice)
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
	local api = require("mdemg.api.learning")
	local float = require("mdemg.ui.float")

	if sub == "stats" then
		api.stats(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Learning Stats",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
				width = 60,
				height = 20,
			})
		end)
	elseif sub == "freeze" then
		local reason = args and args[2] or "manual freeze from neovim"
		api.freeze(reason, function(err)
			if err then
				notify.error(err)
			else
				notify.info("Learning frozen")
			end
		end)
	elseif sub == "unfreeze" then
		api.unfreeze(function(err)
			if err then
				notify.error(err)
			else
				notify.info("Learning unfrozen")
			end
		end)
	elseif sub == "freeze-status" then
		api.freeze_status(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Freeze Status",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "prune" then
		local dry_run = not (args and args[2] == "--execute")
		api.prune({ dry_run = dry_run }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local prefix = dry_run and "[DRY RUN] " or ""
			float.open({
				title = prefix .. "Prune Results",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "distribution" then
		api.distribution(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Learning Distribution",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
				width = 60,
				height = 20,
			})
		end)
	elseif sub == "frontiers" then
		api.frontiers({ limit = 20 }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Frontier Nodes",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
