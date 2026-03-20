local M = {}
local client = require("mdemg.client")

-- GET /v1/system/capability-gaps
function M.list(callback)
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	client.get("/v1/system/capability-gaps", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/system/capability-gaps/{id}
function M.get(gap_id, callback)
	client.get("/v1/system/capability-gaps/" .. gap_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/system/gap-interviews
function M.interviews(opts, callback)
	opts = opts or {}
	client.get("/v1/system/gap-interviews", {
		params = opts.limit and { limit = tostring(opts.limit) } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/system/gap-interviews/{id}
function M.interview_detail(interview_id, callback)
	client.get("/v1/system/gap-interviews/" .. interview_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/feedback
function M.feedback(content, obs_type, callback)
	local body = {
		content = content,
		obs_type = obs_type or "feedback",
	}
	client.post("/v1/feedback", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
