local M = {}

local subcommands = { "list", "recall", "register" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgSkills:" }, function(choice)
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
	local api = require("mdemg.api.skills")
	local float = require("mdemg.ui.float")
	local picker = require("mdemg.ui.picker")

	if sub == "list" then
		api.list(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local skills = data.skills or {}
			if #skills == 0 then
				notify.info("No skills registered")
				return
			end
			picker.pick(skills, {
				prompt = "Skills",
				format_item = function(s)
					return string.format("%s — %s", s.name or "?", s.description or "")
				end,
				on_select = function(s)
					if s.name then
						M._dispatch("recall", { "recall", s.name })
					end
				end,
			})
		end)
	elseif sub == "recall" then
		local name = args and args[2]
		if not name then
			notify.warn("Usage: MdemgSkills recall <name>")
			return
		end
		api.recall(name, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local lines = {}
			if data.content then
				for _, l in ipairs(vim.split(data.content, "\n")) do
					table.insert(lines, l)
				end
			else
				for _, l in ipairs(vim.split(vim.inspect(data), "\n")) do
					table.insert(lines, l)
				end
			end
			float.open({ title = "Skill: " .. name, content = lines, filetype = "markdown", modifiable = false })
		end)
	elseif sub == "register" then
		local name = args and args[2]
		if not name then
			notify.warn("Usage: MdemgSkills register <name>")
			return
		end
		vim.ui.input({ prompt = "Description: " }, function(desc)
			if not desc or desc == "" then
				return
			end
			api.register(name, { description = desc }, function(err)
				if err then
					notify.error(err)
				else
					notify.info("Skill registered: " .. name)
				end
			end)
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
