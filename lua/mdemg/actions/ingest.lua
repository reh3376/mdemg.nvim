local M = {}

local subcommands = { "trigger", "status", "cancel", "jobs", "files" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgIngest:" }, function(choice)
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
	local api = require("mdemg.api.ingest")
	local float = require("mdemg.ui.float")
	local progress = require("mdemg.ui.progress")

	if sub == "trigger" then
		local path = (args and args[2]) or vim.fn.getcwd()
		notify.info("Triggering ingestion: " .. path)
		api.trigger(path, {}, function(err, data)
			if err then
				notify.error("Ingest trigger failed: " .. err)
				return
			end
			notify.info("Job created: " .. (data.job_id or "?"))
			if data.job_id then
				progress.stream(data.job_id)
			end
		end)
	elseif sub == "status" then
		local job_id = args and args[2]
		if not job_id then
			notify.warn("Usage: MdemgIngest status <job_id>")
			return
		end
		api.status(job_id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local p = data.progress or {}
			float.open({
				title = "Ingest Status",
				content = {
					"# Job: " .. (data.job_id or "?"),
					"",
					"**Status:** " .. (data.status or "?"),
					"**Phase:** " .. (p.phase or "?"),
					"**Progress:** " .. string.format("%.1f%%", p.percentage or 0),
					string.format("**Items:** %d / %d", p.current or 0, p.total or 0),
					"**Rate:** " .. (p.rate or "?"),
				},
				filetype = "markdown",
				modifiable = false,
				width = 50,
				height = 12,
			})
		end)
	elseif sub == "cancel" then
		local job_id = args and args[2]
		if not job_id then
			notify.warn("Usage: MdemgIngest cancel <job_id>")
			return
		end
		api.cancel(job_id, function(err)
			if err then
				notify.error(err)
			else
				notify.info("Job cancelled: " .. job_id)
			end
		end)
	elseif sub == "jobs" then
		api.jobs(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local jobs = data.jobs or {}
			if #jobs == 0 then
				notify.info("No ingest jobs")
				return
			end
			local lines = { "# Ingest Jobs", "" }
			for _, j in ipairs(jobs) do
				table.insert(
					lines,
					string.format("- **%s** — %s (%s)", j.job_id or "?", j.status or "?", j.created_at or "?")
				)
			end
			float.open({ title = "Ingest Jobs", content = lines, filetype = "markdown", modifiable = false })
		end)
	elseif sub == "files" then
		local filepath = vim.fn.expand("%:p")
		if filepath == "" then
			notify.warn("No file open")
			return
		end
		api.files({ filepath }, function(err, data)
			if err then
				notify.error(err)
			else
				notify.info(string.format("Ingested %d file(s)", data.success_count or 0))
			end
		end)
	else
		notify.warn("Unknown subcommand: " .. sub .. ". Options: " .. table.concat(subcommands, ", "))
	end
end

return M
