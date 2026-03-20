local M = {}

local subcommands = { "list", "modules", "ape-status", "ape-trigger", "detail", "module-detail" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgPlugins:" }, function(choice)
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
	local api = require("mdemg.api.plugins")
	local float = require("mdemg.ui.float")
	local picker = require("mdemg.ui.picker")

	if sub == "list" then
		api.list(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local plugins = data.plugins or (data.data and data.data.plugins) or {}
			if #plugins == 0 then
				notify.info("No plugins registered")
				return
			end
			picker.pick(plugins, {
				prompt = "Plugins",
				format_item = function(p)
					return string.format("%s [%s] v%s", p.name or "?", p.type or "?", p.version or "?")
				end,
				on_select = function(p)
					float.open({
						title = p.name or "Plugin",
						content = vim.split(vim.inspect(p), "\n"),
						modifiable = false,
					})
				end,
			})
		end)
	elseif sub == "modules" then
		api.list_modules(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local modules = data.modules or (data.data and data.data.modules) or {}
			if #modules == 0 then
				notify.info("No modules found")
				return
			end
			picker.pick(modules, {
				prompt = "Modules",
				format_item = function(m)
					return string.format("%s — %s", m.name or m.id or "?", m.enabled and "enabled" or "disabled")
				end,
				on_select = function(m)
					float.open({
						title = m.name or "Module",
						content = vim.split(vim.inspect(m), "\n"),
						modifiable = false,
					})
				end,
			})
		end)
	elseif sub == "ape-status" then
		api.ape_status(function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "APE Status",
				content = vim.split(vim.inspect(data.data or data), "\n"),
				modifiable = false,
			})
		end)
	elseif sub == "ape-trigger" then
		local event = args and args[2] or "consolidate"
		notify.info("Triggering APE: " .. event)
		api.ape_trigger({ event = event }, function(err, data)
			if err then
				notify.error(err)
			else
				notify.info("APE triggered: " .. (data.data and data.data.message or "OK"))
			end
		end)
	elseif sub == "detail" then
		local id = args and args[2]
		if not id then
			notify.warn("Usage: MdemgPlugins detail <id>")
			return
		end
		api.get(id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Plugin: " .. id, content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "module-detail" then
		local id = args and args[2]
		if not id then
			notify.warn("Usage: MdemgPlugins module-detail <id>")
			return
		end
		api.get_module(id, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Module: " .. id, content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
