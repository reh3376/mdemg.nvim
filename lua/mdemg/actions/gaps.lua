local M = {}

local subcommands = { "list", "detail", "interviews", "interview-detail", "feedback" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgGaps:" }, function(choice)
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
	local api = require("mdemg.api.gaps")
	local float = require("mdemg.ui.float")
	local picker = require("mdemg.ui.picker")

	if sub == "list" then
		api.list(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local gaps = data.gaps or data.capability_gaps or {}
			if #gaps == 0 then
				notify.info("No capability gaps found")
				return
			end
			picker.pick(gaps, {
				prompt = "Capability Gaps",
				format_item = function(g)
					return string.format("[%s] %s", g.severity or "?", g.description or g.name or "?")
				end,
				on_select = function(g)
					float.open({
						title = g.name or "Gap Detail",
						content = vim.split(vim.inspect(g), "\n"),
						modifiable = false,
					})
				end,
			})
		end)
	elseif sub == "detail" then
		local gap_id = args and args[2]
		if not gap_id then
			notify.warn("Usage: MdemgGaps detail <gap_id>")
			return
		end
		api.get(gap_id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Gap: " .. gap_id, content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "interviews" then
		api.interviews({ limit = 20 }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local interviews = data.interviews or {}
			if #interviews == 0 then
				notify.info("No gap interviews found")
				return
			end
			picker.pick(interviews, {
				prompt = "Gap Interviews",
				format_item = function(i)
					return string.format("%s — %s", i.interview_id or "?", i.status or "?")
				end,
				on_select = function(i)
					float.open({
						title = "Interview: " .. (i.interview_id or "?"),
						content = vim.split(vim.inspect(i), "\n"),
						modifiable = false,
					})
				end,
			})
		end)
	elseif sub == "interview-detail" then
		local interview_id = args and args[2]
		if not interview_id then
			notify.warn("Usage: MdemgGaps interview-detail <interview_id>")
			return
		end
		api.interview_detail(interview_id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Interview: " .. interview_id,
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "feedback" then
		vim.ui.input({ prompt = "Feedback: " }, function(content)
			if not content or content == "" then
				return
			end
			api.feedback(content, "feedback", function(err)
				if err then
					notify.error(err)
				else
					notify.info("Feedback submitted")
				end
			end)
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
