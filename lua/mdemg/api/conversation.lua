local M = {}
local client = require("mdemg.client")

function M.resume(session_id, opts, callback)
	opts = opts or {}
	local body = {
		session_id = session_id or vim.g.mdemg_session_id,
		include_tasks = opts.include_tasks,
		include_decisions = opts.include_decisions,
		include_learnings = opts.include_learnings,
		max_observations = opts.max_observations or 20,
		agent_id = opts.agent_id,
	}
	client.post("/v1/conversation/resume", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.consolidate(session_id, callback)
	local body = {
		session_id = session_id or vim.g.mdemg_session_id,
	}
	client.post("/v1/conversation/consolidate", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.observe(content, obs_type, opts, callback)
	opts = opts or {}
	local body = {
		session_id = vim.g.mdemg_session_id,
		content = content,
		obs_type = obs_type or "learning",
		tags = opts.tags,
		metadata = opts.metadata,
		user_id = opts.user_id,
		visibility = opts.visibility or "private",
		agent_id = opts.agent_id,
		refers_to = opts.refers_to,
		pinned = opts.pinned,
	}
	client.post("/v1/conversation/observe", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/conversation/correct
function M.correct(incorrect, correct_text, opts, callback)
	opts = opts or {}
	local body = {
		session_id = vim.g.mdemg_session_id,
		incorrect = incorrect,
		correct = correct_text,
		context = opts.context,
		user_id = opts.user_id,
		visibility = opts.visibility or "private",
		agent_id = opts.agent_id,
		refers_to = opts.refers_to,
	}
	client.post("/v1/conversation/correct", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/conversation/recall
function M.recall(query, opts, callback)
	opts = opts or {}
	local body = {
		query = query,
		top_k = opts.top_k or 10,
		include_themes = opts.include_themes,
		include_concepts = opts.include_concepts,
		temporal_after = opts.temporal_after,
		temporal_before = opts.temporal_before,
		filter_tags = opts.filter_tags,
	}
	client.post("/v1/conversation/recall", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/conversation/volatile/stats
function M.volatile_stats(callback)
	local space_id = require("mdemg.client").resolve_space_id()
	client.get("/v1/conversation/volatile/stats", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/conversation/graduate
function M.graduate(callback)
	local body = {
		session_id = vim.g.mdemg_session_id,
	}
	client.post("/v1/conversation/graduate", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/conversation/session/health
function M.session_health(callback)
	local session_id = vim.g.mdemg_session_id
	client.get("/v1/conversation/session/health", {
		params = session_id and { session_id = session_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/conversation/session/anomalies
function M.session_anomalies(callback)
	local session_id = vim.g.mdemg_session_id
	client.get("/v1/conversation/session/anomalies", {
		params = session_id and { session_id = session_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
