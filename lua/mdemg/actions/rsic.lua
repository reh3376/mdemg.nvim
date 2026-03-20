local M = {}

local subcommands = { "cycle", "assess", "report", "history", "calibration", "health", "signals", "rollback", "reset" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgRSIC:" }, function(choice)
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
	local api = require("mdemg.api.rsic")
	local float = require("mdemg.ui.float")

	if sub == "cycle" then
		local dry_run = args and args[2] == "--dry-run"
		notify.info("Running RSIC cycle" .. (dry_run and " (dry run)" or "") .. "...")
		api.cycle({ dry_run = dry_run }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "RSIC Cycle Result",
				content = vim.split(vim.inspect(data), "\n"),
				filetype = "lua",
				modifiable = false,
			})
		end)
	elseif sub == "assess" then
		api.assess({}, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Assessment", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "report" then
		local task_id = args and args[2]
		if task_id then
			api.report_detail(task_id, function(err, data)
				if err then
					notify.error(err)
					return
				end
				float.open({
					title = "Report: " .. task_id,
					content = vim.split(vim.inspect(data), "\n"),
					modifiable = false,
				})
			end)
		else
			api.report(function(err, data)
				if err then
					notify.error(err)
					return
				end
				float.open({ title = "RSIC Report", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
			end)
		end
	elseif sub == "history" then
		api.history({ limit = 20 }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Cycle History", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "calibration" then
		api.calibration(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Calibration", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "health" then
		api.health(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "RSIC Health", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "signals" then
		api.signals(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Signals", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "rollback" then
		local cycle_id = args and args[2]
		if not cycle_id then
			notify.warn("Usage: MdemgRSIC rollback <cycle_id>")
			return
		end
		api.rollback(cycle_id, function(err, data)
			if err then
				notify.error(err)
			else
				notify.info("Rollback complete")
			end
		end)
	elseif sub == "reset" then
		api.reset({}, function(err)
			if err then
				notify.error(err)
			else
				notify.info("Orchestration reset")
			end
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
