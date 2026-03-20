local M = {}

local subcommands = {
	"observe",
	"correct",
	"recall",
	"resume",
	"consolidate",
	"graduate",
	"volatile-stats",
	"session-health",
}

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgConversation:" }, function(choice)
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
	local api = require("mdemg.api.conversation")
	local float = require("mdemg.ui.float")

	if sub == "observe" then
		vim.ui.input({ prompt = "Observation: " }, function(content)
			if not content or content == "" then
				return
			end
			vim.ui.select(
				{ "learning", "decision", "correction", "preference", "error", "technical_note", "insight" },
				{ prompt = "Type:" },
				function(obs_type)
					if not obs_type then
						return
					end
					api.observe(content, obs_type, {}, function(err, data)
						if err then
							notify.error(err)
						else
							local msg = string.format(
								"Observed (%s) surprise=%.2f",
								data.node_id or "?",
								data.surprise_score or 0
							)
							notify.info(msg)
						end
					end)
				end
			)
		end)
	elseif sub == "correct" then
		vim.ui.input({ prompt = "What was wrong: " }, function(incorrect)
			if not incorrect or incorrect == "" then
				return
			end
			vim.ui.input({ prompt = "What is correct: " }, function(correct)
				if not correct or correct == "" then
					return
				end
				api.correct(incorrect, correct, {}, function(err, data)
					if err then
						notify.error(err)
					else
						notify.info("Correction recorded (" .. (data.node_id or "?") .. ")")
					end
				end)
			end)
		end)
	elseif sub == "recall" then
		vim.ui.input({ prompt = "Recall query: " }, function(query)
			if not query or query == "" then
				return
			end
			api.recall(query, { include_themes = true }, function(err, data)
				if err then
					notify.error(err)
					return
				end
				local results = data.results or {}
				if #results == 0 then
					notify.warn("No conversation memories found")
					return
				end
				local lines = { "# Conversation Recall: " .. query, "" }
				for _, r in ipairs(results) do
					table.insert(lines, "### " .. (r.type or "?") .. " — " .. (r.node_id or ""))
					table.insert(
						lines,
						string.format("**Score:** %.3f | **Layer:** %s", r.score or 0, tostring(r.layer or "?"))
					)
					if r.content then
						table.insert(lines, "")
						table.insert(lines, r.content)
					end
					table.insert(lines, "")
				end
				float.open({ title = "Conversation Recall", content = lines, filetype = "markdown", modifiable = false })
			end)
		end)
	elseif sub == "resume" then
		local session_id = args and args[2] or vim.g.mdemg_session_id
		api.resume(session_id, { max_observations = 20 }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local obs = data.observations or {}
			notify.info(string.format("Resumed: %d observations, %d themes", #obs, #(data.themes or {})))
		end)
	elseif sub == "consolidate" then
		api.consolidate(vim.g.mdemg_session_id, function(err)
			if err then
				notify.error(err)
			else
				notify.info("Session consolidated")
			end
		end)
	elseif sub == "graduate" then
		api.graduate(function(err, data)
			if err then
				notify.error(err)
			else
				notify.info("Graduation complete")
			end
		end)
	elseif sub == "volatile-stats" then
		api.volatile_stats(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Volatile Stats",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
				width = 60,
				height = 15,
			})
		end)
	elseif sub == "session-health" then
		api.session_health(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Session Health",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
				width = 60,
				height = 15,
			})
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
