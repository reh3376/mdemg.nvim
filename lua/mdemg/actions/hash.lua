local M = {}

local subcommands = { "register", "files", "verify", "verify-all", "update", "revert", "scan", "lookup" }

function M.run(args)
	local sub = args and args[1] or nil
	if not sub then
		vim.ui.select(subcommands, { prompt = "MdemgHash:" }, function(choice)
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
	local api = require("mdemg.api.hash")
	local float = require("mdemg.ui.float")

	if sub == "register" then
		local base_path = args and args[2] or vim.fn.getcwd()
		notify.info("Registering hashes for: " .. base_path)
		api.register(base_path, function(err, data)
			if err then
				notify.error(err)
				return
			end
			notify.info(string.format("Registered %d files", data.registered or data.count or 0))
		end)
	elseif sub == "files" then
		api.files(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local files = data.files or {}
			if #files == 0 then
				notify.info("No tracked files")
				return
			end
			local lines = { "# Tracked Files", "" }
			for _, f in ipairs(files) do
				local status = f.verified and "OK" or "UNVERIFIED"
				table.insert(
					lines,
					string.format("- **%s** `%s` — %s", f.path or "?", (f.hash or "?"):sub(1, 12), status)
				)
			end
			float.open({ title = "Hash Files", content = lines, filetype = "markdown", modifiable = false })
		end)
	elseif sub == "verify" then
		local file_path = args and args[2] or vim.fn.expand("%:p")
		api.verify(file_path, function(err, data)
			if err then
				notify.error(err)
				return
			end
			if data.verified then
				notify.info("File verified: " .. file_path)
			else
				notify.warn("File MODIFIED: " .. file_path .. (data.reason and (" — " .. data.reason) or ""))
			end
		end)
	elseif sub == "verify-all" then
		notify.info("Verifying all tracked files...")
		api.verify_all(function(err, data)
			if err then
				notify.error(err)
				return
			end
			local lines = { "# Verification Results", "" }
			table.insert(lines, string.format("**Total:** %d", data.total or 0))
			table.insert(lines, string.format("**Verified:** %d", data.verified or 0))
			table.insert(lines, string.format("**Modified:** %d", data.modified or 0))
			if data.modified_files then
				table.insert(lines, "")
				table.insert(lines, "## Modified Files")
				for _, f in ipairs(data.modified_files) do
					table.insert(lines, "- " .. (type(f) == "string" and f or f.path or "?"))
				end
			end
			float.open({ title = "Verify All", content = lines, filetype = "markdown", modifiable = false })
		end)
	elseif sub == "update" then
		local file_path = args and args[2] or vim.fn.expand("%:p")
		api.update(file_path, function(err)
			if err then
				notify.error(err)
			else
				notify.info("Hash updated: " .. file_path)
			end
		end)
	elseif sub == "revert" then
		local file_path = args and args[2] or vim.fn.expand("%:p")
		api.revert(file_path, function(err)
			if err then
				notify.error(err)
			else
				notify.info("File reverted: " .. file_path)
			end
		end)
	elseif sub == "scan" then
		local base_path = args and args[2] or vim.fn.getcwd()
		notify.info("Scanning: " .. base_path)
		api.scan(base_path, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({ title = "Scan Results", content = vim.split(vim.inspect(data), "\n"), modifiable = false })
		end)
	elseif sub == "lookup" then
		local hash = args and args[2]
		if not hash then
			notify.warn("Usage: MdemgHash lookup <hash>")
			return
		end
		api.get_by_hash(hash, function(err, data)
			if err then
				notify.error(err)
				return
			end
			float.open({
				title = "Hash: " .. hash:sub(1, 12),
				content = vim.split(vim.inspect(data), "\n"),
				modifiable = false,
			})
		end)
	else
		notify.warn("Unknown subcommand: " .. sub)
	end
end

return M
