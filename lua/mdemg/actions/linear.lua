local M = {}

local subcommands = { "issues", "issue-detail", "projects", "project-detail", "comments", "create-comment" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgLinear:" }, function(choice)
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
	local api = require("mdemg.api.linear")
	local float = require("mdemg.ui.float")
	local picker = require("mdemg.ui.picker")

	if sub == "issues" then
		api.list_issues({}, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local issues = data.issues or data.data or {}
			if #issues == 0 then
				notify.info("No issues found")
				return
			end
			picker.pick(issues, {
				prompt = "Linear Issues",
				format_item = function(i)
					return string.format("[%s] %s — %s", i.identifier or "?", i.title or "?", i.state or "?")
				end,
				on_select = function(i)
					float.open({
						title = i.title or "Issue",
						content = vim.split(vim.inspect(i), "\n"),
						modifiable = false,
					})
				end,
			})
		end)
	elseif sub == "issue-detail" then
		local id = args and args[2]
		if not id then
			notify.warn("Usage: MdemgLinear issue-detail <id>")
			return
		end
		api.get_issue(id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Issue: " .. id,
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "projects" then
		api.list_projects({}, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local projects = data.projects or data.data or {}
			if #projects == 0 then
				notify.info("No projects found")
				return
			end
			picker.pick(projects, {
				prompt = "Linear Projects",
				format_item = function(p)
					return string.format("%s — %s", p.name or "?", p.state or "?")
				end,
				on_select = function(p)
					float.open({
						title = p.name or "Project",
						content = vim.split(vim.inspect(p), "\n"),
						modifiable = false,
					})
				end,
			})
		end)
	elseif sub == "project-detail" then
		local id = args and args[2]
		if not id then
			notify.warn("Usage: MdemgLinear project-detail <id>")
			return
		end
		api.get_project(id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Project: " .. id,
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "comments" then
		api.list_comments({}, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local comments = data.comments or data.data or {}
			if #comments == 0 then
				notify.info("No comments found")
				return
			end
			local lines = { "# Linear Comments", "" }
			for _, c in ipairs(comments) do
				table.insert(lines, string.format("**%s** (%s):", c.user or "?", c.created_at or "?"))
				table.insert(lines, c.body or "")
				table.insert(lines, "")
			end
			float.open({ title = "Comments", content = lines, filetype = "markdown", modifiable = false })
		end)
	elseif sub == "create-comment" then
		local issue_id = args and args[2]
		if not issue_id then
			notify.warn("Usage: MdemgLinear create-comment <issue_id>")
			return
		end
		vim.ui.input({ prompt = "Comment: " }, function(body)
			if not body or body == "" then
				return
			end
			api.create_comment({ issue_id = issue_id, body = body }, function(err)
				if err then
					notify.error(err)
				else
					notify.info("Comment created")
				end
			end)
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
