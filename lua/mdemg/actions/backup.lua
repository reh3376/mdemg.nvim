local M = {}

local subcommands = { "trigger", "list", "status", "manifest", "restore", "delete" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgBackup:" }, function(choice)
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
	local api = require("mdemg.api.backup")
	local float = require("mdemg.ui.float")
	local picker = require("mdemg.ui.picker")

	if sub == "trigger" then
		notify.info("Triggering backup...")
		api.trigger({}, function(err, data)
			if err then
				notify.error(err)
				return
			end
			notify.info("Backup started: " .. (data.backup_id or "?"))
		end)
	elseif sub == "list" then
		api.list({}, function(err, data)
			if err then
				notify.error(err)
				return
			end
			local backups = data.backups or {}
			if #backups == 0 then
				notify.info("No backups found")
				return
			end
			picker.pick(backups, {
				prompt = "Backups",
				format_item = function(b)
					return string.format("%s — %s (%s)", b.backup_id or "?", b.type or "?", b.created_at or "?")
				end,
				on_select = function(b)
					float.open({
						title = "Backup: " .. (b.backup_id or "?"),
						content = vim.split(vim.inspect(b), "\n"),
						modifiable = false,
					})
				end,
			})
		end)
	elseif sub == "status" then
		local backup_id = args and args[2]
		if not backup_id then
			notify.warn("Usage: MdemgBackup status <backup_id>")
			return
		end
		api.status(backup_id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Backup Status", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "manifest" then
		local backup_id = args and args[2]
		if not backup_id then
			notify.warn("Usage: MdemgBackup manifest <backup_id>")
			return
		end
		api.manifest(backup_id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Manifest", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "restore" then
		local backup_id = args and args[2]
		if not backup_id then
			notify.warn("Usage: MdemgBackup restore <backup_id> [target_space]")
			return
		end
		local target = args and args[3]
		api.restore(backup_id, target, function(err, data)
			if err then
				notify.error(err)
			else
				notify.info("Restore started: " .. (data.restore_id or "?"))
			end
		end)
	elseif sub == "delete" then
		local backup_id = args and args[2]
		if not backup_id then
			notify.warn("Usage: MdemgBackup delete <backup_id>")
			return
		end
		api.delete(backup_id, function(err)
			if err then
				notify.error(err)
			else
				notify.info("Backup deleted: " .. backup_id)
			end
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
