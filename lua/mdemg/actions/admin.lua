local M = {}

local subcommands = { "spaces", "space-detail", "prune", "export-preview", "export", "import", "meta-learn" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgAdmin:" }, function(choice)
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
	local api = require("mdemg.api.admin")
	local float = require("mdemg.ui.float")
	local picker = require("mdemg.ui.picker")

	if sub == "spaces" then
		api.list_spaces(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local spaces = data.spaces or {}
			if #spaces == 0 then
				notify.info("No spaces found")
				return
			end
			picker.pick(spaces, {
				prompt = "Spaces",
				format_item = function(s)
					return string.format(
						"%s — %d nodes (%s)",
						s.space_id or s.name or "?",
						s.node_count or 0,
						s.prunable and "prunable" or "protected"
					)
				end,
				on_select = function(s)
					if s.space_id then
						M._dispatch("space-detail", { "space-detail", s.space_id })
					end
				end,
			})
		end)
	elseif sub == "space-detail" then
		local space_id = args and args[2]
		if not space_id then
			notify.warn("Usage: MdemgAdmin space-detail <space_id>")
			return
		end
		api.get_space(space_id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Space: " .. space_id,
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "prune" then
		local dry_run = not (args and args[2] == "--execute")
		api.prune_spaces({ dry_run = dry_run }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local prefix = dry_run and "[DRY RUN] " or ""
			float.open({
				title = prefix .. "Space Prune",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "export-preview" then
		local space_id = args and args[2] or vim.b.mdemg_space_id or vim.g.mdemg_space_id
		if not space_id then
			notify.warn("Usage: MdemgAdmin export-preview <space_id>")
			return
		end
		api.export_preview({ space_id = space_id }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Export Preview: " .. space_id,
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "export" then
		local space_id = args and args[2] or vim.b.mdemg_space_id or vim.g.mdemg_space_id
		local profile = args and args[3] or "metadata"
		if not space_id then
			notify.warn("Usage: MdemgAdmin export <space_id> [profile]")
			return
		end
		notify.info("Exporting space: " .. space_id .. " (profile: " .. profile .. ")")
		api.export({ space_id = space_id, profile = profile }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Export: " .. space_id,
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "import" then
		notify.warn("Import requires a structured payload — use the API directly")
	elseif sub == "meta-learn" then
		local space_id = args and args[2] or vim.b.mdemg_space_id or vim.g.mdemg_space_id
		notify.info("Running meta-learning...")
		api.meta_learn({ space_id = space_id }, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Meta-Learning Results",
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
