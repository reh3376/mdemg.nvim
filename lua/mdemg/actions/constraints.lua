local M = {}

local subcommands = { "list", "stats", "effectiveness", "conflicts", "detect-conflicts" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgConstraints:" }, function(choice)
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
	local api = require("mdemg.api.constraints")
	local float = require("mdemg.ui.float")
	local picker = require("mdemg.ui.picker")

	if sub == "list" then
		api.list(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local constraints = data.constraints or {}
			if #constraints == 0 then
				notify.info("No constraints found")
				return
			end
			picker.pick(constraints, {
				prompt = "Constraints",
				format_item = function(c)
					return string.format("[%s] %s", c.constraint_type or c.type or "?", c.name or c.description or "?")
				end,
				on_select = function(c)
					float.open({
						title = c.name or "Constraint",
						content = vim.split(vim.inspect(c), "\n"),
						modifiable = false,
					})
				end,
			})
		end)
	elseif sub == "stats" then
		api.stats(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Constraint Stats",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
				width = 60,
				height = 15,
			})
		end)
	elseif sub == "effectiveness" then
		local constraint_id = args and args[2]
		api.effectiveness(constraint_id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Effectiveness",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "conflicts" then
		api.conflicts(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Constraint Conflicts",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "detect-conflicts" then
		api.detect_conflicts(nil, function(err, data)
			if err then
				notify.error(err)
				return
			end
			notify.info("Conflict detection complete")
			float.open({
				title = "Detected Conflicts",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
