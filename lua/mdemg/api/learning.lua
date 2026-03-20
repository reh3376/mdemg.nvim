local M = {}
local client = require("mdemg.client")

-- POST /v1/learning/freeze
function M.freeze(reason, callback)
	local body = { reason = reason or "manual freeze from neovim" }
	client.post("/v1/learning/freeze", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/learning/unfreeze
function M.unfreeze(callback)
	client.post("/v1/learning/unfreeze", {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/learning/freeze/status
function M.freeze_status(callback)
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	client.get("/v1/learning/freeze/status", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/learning/prune
function M.prune(opts, callback)
	opts = opts or {}
	local body = {
		threshold = opts.threshold,
		dry_run = opts.dry_run,
	}
	client.post("/v1/learning/prune", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/learning/stats
function M.stats(callback)
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	client.get("/v1/learning/stats", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/learning/negative-feedback
function M.negative_feedback(query_node_ids, rejected_node_ids, callback)
	local body = {
		query_node_ids = query_node_ids,
		rejected_node_ids = rejected_node_ids,
	}
	client.post("/v1/learning/negative-feedback", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/memory/frontiers
function M.frontiers(opts, callback)
	opts = opts or {}
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	local params = {}
	if space_id then
		params.space_id = space_id
	end
	if opts.limit then
		params.limit = tostring(opts.limit)
	end
	client.get("/v1/memory/frontiers", {
		params = params,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/memory/distribution
function M.distribution(callback)
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	client.get("/v1/memory/distribution", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
