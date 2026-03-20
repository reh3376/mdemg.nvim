local M = {}
local client = require("mdemg.client")

-- POST /v1/memory/ingest/trigger
function M.trigger(path, opts, callback)
	opts = opts or {}
	local body = {
		path = path,
		batch_size = opts.batch_size,
		workers = opts.workers,
		timeout_seconds = opts.timeout_seconds,
		extract_symbols = opts.extract_symbols ~= false,
		consolidate = opts.consolidate,
		include_tests = opts.include_tests,
		incremental = opts.incremental,
		dry_run = opts.dry_run,
		since_commit = opts.since_commit,
		exclude_dirs = opts.exclude_dirs,
		limit = opts.limit,
	}
	client.post("/v1/memory/ingest/trigger", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
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

-- POST /v1/memory/ingest/cancel/{job_id}
function M.cancel(job_id, callback)
	client.post("/v1/memory/ingest/cancel/" .. job_id, {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/memory/ingest/jobs
function M.jobs(callback)
	client.get("/v1/memory/ingest/jobs", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/memory/ingest/files (re-exported from memory for convenience)
function M.files(paths, callback)
	local body = {
		files = paths,
		extract_symbols = true,
	}
	client.post("/v1/memory/ingest/files", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
