local M = {}
local client = require("mdemg.client")

-- POST /v1/self-improve/assess
function M.assess(opts, callback)
	opts = opts or {}
	local body = { tier = opts.tier }
	client.post("/v1/self-improve/assess", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/self-improve/report
function M.report(callback)
	client.get("/v1/self-improve/report", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/self-improve/report/{task_id}
function M.report_detail(task_id, callback)
	client.get("/v1/self-improve/report/" .. task_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/self-improve/cycle
function M.cycle(opts, callback)
	opts = opts or {}
	local body = {
		tier = opts.tier,
		trigger_source = opts.trigger_source or "neovim",
		idempotency_key = opts.idempotency_key,
		dry_run = opts.dry_run,
	}
	client.post("/v1/self-improve/cycle", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/self-improve/history
function M.history(opts, callback)
	opts = opts or {}
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	local params = {}
	if space_id then
		params.space_id = space_id
	end
	if opts.limit then
		params.limit = tostring(opts.limit)
	end
	client.get("/v1/self-improve/history", {
		params = params,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/self-improve/calibration
function M.calibration(callback)
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	client.get("/v1/self-improve/calibration", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/self-improve/orchestration/reset
function M.reset(opts, callback)
	opts = opts or {}
	local body = { tier = opts.tier }
	client.post("/v1/self-improve/orchestration/reset", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/self-improve/health
function M.health(callback)
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	client.get("/v1/self-improve/health", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/self-improve/signals
function M.signals(callback)
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	client.get("/v1/self-improve/signals", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/self-improve/rollback
function M.rollback(cycle_id, callback)
	local body = { cycle_id = cycle_id }
	client.post("/v1/self-improve/rollback", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
