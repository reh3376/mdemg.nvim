local M = {}

function M.setup()
	local cfg = require("mdemg.config").get()
	if not cfg.session.auto_create then
		return
	end

	local group = vim.api.nvim_create_augroup("MdemgSession", { clear = true })

	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		callback = function()
			M.create_session()
		end,
	})

	if cfg.session.auto_consolidate then
		vim.api.nvim_create_autocmd("VimLeavePre", {
			group = group,
			callback = function()
				M.consolidate()
			end,
		})
	end
end

function M.create_session()
	local timestamp = os.time()
	local hostname = vim.fn.hostname() or "unknown"
	local pid = vim.fn.getpid()
	local seed = hostname .. tostring(pid) .. tostring(timestamp) .. tostring(math.random(100000))
	local hash = vim.fn.sha256(seed):sub(1, 12)
	local session_id = string.format("nvim-%d-%s", timestamp, hash)
	vim.g.mdemg_session_id = session_id
end

function M.resume(session_id)
	local conversation = require("mdemg.api.conversation")
	local notify = require("mdemg.ui.notify")

	conversation.resume(session_id, { max_observations = 10 }, function(err, data)
		if err then
			notify.warn("Session resume failed: " .. err)
			return
		end
		if data and data.observations then
			notify.info(string.format("Resumed session with %d observations", #data.observations))
		end
	end)
end

function M.consolidate()
	local session_id = vim.g.mdemg_session_id
	if not session_id then
		return
	end

	local endpoint = vim.b.mdemg_endpoint or vim.g.mdemg_endpoint or require("mdemg.config").get().endpoint
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	if not space_id then
		return
	end

	local body = vim.json.encode({
		space_id = space_id,
		session_id = session_id,
	})
	vim.fn.system({
		"curl",
		"-s",
		"-X",
		"POST",
		endpoint .. "/v1/conversation/consolidate",
		"-H",
		"Content-Type: application/json",
		"-d",
		body,
		"--max-time",
		"5",
	})
end

return M
