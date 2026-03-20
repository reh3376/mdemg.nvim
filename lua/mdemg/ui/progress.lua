local M = {}

-- Track active progress floats
M._active = {}

-- Open a progress display for a job
function M.open(job_id)
	local float = require("mdemg.ui.float")

	local lines = {
		"# Job: " .. job_id,
		"",
		"**Status:** pending",
		"**Progress:** 0%",
		"",
		"Waiting for updates...",
	}

	local state = float.open({
		title = "Job Progress",
		content = lines,
		filetype = "markdown",
		modifiable = false,
		width = 50,
		height = 12,
		on_close = function()
			M._active[job_id] = nil
		end,
	})

	M._active[job_id] = state
	return state
end

-- Update progress display from SSE event
function M.update(job_id, event)
	local state = M._active[job_id]
	if not state then
		return
	end
	local float = require("mdemg.ui.float")

	local progress = event.progress or {}
	local pct = progress.percentage or 0
	local bar_width = 30
	local filled = math.floor(pct / 100 * bar_width)
	local bar = string.rep("=", filled) .. string.rep("-", bar_width - filled)

	local lines = {
		"# Job: " .. job_id,
		"",
		"**Status:** " .. (event.status or "running"),
		"**Phase:** " .. (progress.phase or "?"),
		"",
		"[" .. bar .. "] " .. string.format("%.1f%%", pct),
		"",
		string.format("%d / %d", progress.current or 0, progress.total or 0),
	}
	if progress.rate then
		table.insert(lines, "**Rate:** " .. progress.rate)
	end

	float.update(state, lines)
end

-- Mark job complete
function M.complete(job_id, message)
	local state = M._active[job_id]
	if not state then
		return
	end
	local float = require("mdemg.ui.float")

	float.update(state, {
		"# Job: " .. job_id,
		"",
		"**Status:** completed",
		"",
		message or "Job finished successfully.",
	})

	-- Auto-close after 3 seconds
	vim.defer_fn(function()
		if M._active[job_id] then
			float.close(M._active[job_id])
			M._active[job_id] = nil
		end
	end, 3000)
end

-- Mark job failed
function M.error(job_id, err_msg)
	local state = M._active[job_id]
	if not state then
		return
	end
	local float = require("mdemg.ui.float")

	float.update(state, {
		"# Job: " .. job_id,
		"",
		"**Status:** FAILED",
		"",
		"**Error:** " .. (err_msg or "Unknown error"),
	})
end

-- Start streaming progress for a job
function M.stream(job_id)
	local jobs = require("mdemg.api.jobs")
	local notify = require("mdemg.ui.notify")

	M.open(job_id)

	jobs.stream(job_id, {}, {
		on_progress = function(event)
			M.update(job_id, event)
		end,
		on_complete = function(event)
			M.complete(job_id, "Completed: " .. (event.message or ""))
		end,
		on_error = function(err)
			M.error(job_id, err)
			notify.error("Job " .. job_id .. " failed: " .. err)
		end,
	})
end

return M
