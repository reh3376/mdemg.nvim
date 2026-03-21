local M = {}

local subcommands = { "scrape", "list", "status", "cancel", "review" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgScraper:" }, function(choice)
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
	local api = require("mdemg.api.scraper")
	local float = require("mdemg.ui.float")

	if sub == "scrape" then
		vim.ui.input({ prompt = "URL(s) (comma-separated): " }, function(urls_str)
			if not urls_str or urls_str == "" then
				return
			end
			local urls = vim.split(urls_str, ",")
			for i, u in ipairs(urls) do
				urls[i] = vim.trim(u)
			end
			local space_id = require("mdemg.client").resolve_space_id() or "default"
			api.create(urls, space_id, function(err, data)
				if err then
					notify.error(err)
					return
				end
				notify.info("Scrape job created: " .. (data.job_id or "?"))
			end)
		end)
	elseif sub == "list" then
		api.list({}, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local jobs = data.jobs or {}
			if #jobs == 0 then
				notify.info("No scraper jobs")
				return
			end
			local lines = { "# Scraper Jobs", "" }
			for _, j in ipairs(jobs) do
				local line = string.format(
					"- **%s** — %s (%d/%d URLs)",
					j.job_id or "?",
					j.status or "?",
					j.processed_urls or 0,
					j.total_urls or 0
				)
				table.insert(lines, line)
			end
			float.open({ title = "Scraper Jobs", content = lines, filetype = "markdown", modifiable = false })
		end)
	elseif sub == "status" then
		local job_id = args and args[2]
		if not job_id then
			notify.warn("Usage: MdemgScraper status <job_id>")
			return
		end
		api.get(job_id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Scraper: " .. job_id,
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "cancel" then
		local job_id = args and args[2]
		if not job_id then
			notify.warn("Usage: MdemgScraper cancel <job_id>")
			return
		end
		api.cancel(job_id, function(err)
			if err then
				notify.error(err)
			else
				notify.info("Scraper job cancelled")
			end
		end)
	elseif sub == "review" then
		local job_id = args and args[2]
		if not job_id then
			notify.warn("Usage: MdemgScraper review <job_id>")
			return
		end
		api.review(job_id, true, nil, function(err)
			if err then
				notify.error(err)
			else
				notify.info("Scraper job reviewed and approved")
			end
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
