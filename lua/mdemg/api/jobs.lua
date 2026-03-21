local M = {}
local client = require("mdemg.client")

-- GET /v1/jobs/{job_id}/stream (SSE)
-- Returns a handle that can be cancelled
function M.stream(job_id, opts, callbacks)
	opts = opts or {}
	callbacks = callbacks or {}
	local endpoint = require("mdemg.client").resolve_endpoint()
	local url = endpoint .. "/v1/jobs/" .. job_id .. "/stream"

	local args = { "curl", "-s", "-N", url, "--max-time", tostring(opts.timeout or 300) }

	local handle = vim.system(args, {
		text = true,
		stdout = function(_, data)
			if not data then
				return
			end
			vim.schedule(function()
				for line in data:gmatch("[^\n]+") do
					if line:match("^data:") then
						local json_str = line:sub(6)
						local ok, event = pcall(vim.json.decode, json_str)
						if ok and event then
							if event.status == "completed" and callbacks.on_complete then
								callbacks.on_complete(event)
							elseif event.status == "failed" and callbacks.on_error then
								callbacks.on_error(event.error or "Job failed")
							elseif event.progress and callbacks.on_progress then
								callbacks.on_progress(event)
							end
						end
					end
				end
			end)
		end,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 and callbacks.on_error then
				callbacks.on_error(result.stderr or "Stream disconnected")
			end
		end)
	end)

	return handle
end

-- GET /v1/memory/ingest/status/{job_id}
function M.status(job_id, callback)
	client.get("/v1/memory/ingest/status/" .. job_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/memory/ingest/jobs
function M.list(callback)
	client.get("/v1/memory/ingest/jobs", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
