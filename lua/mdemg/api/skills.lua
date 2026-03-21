local M = {}
local client = require("mdemg.client")

-- GET /v1/skills
function M.list(callback)
	local space_id = require("mdemg.client").resolve_space_id()
	client.get("/v1/skills", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/skills/{name}/register
function M.register(name, opts, callback)
	opts = opts or {}
	local body = {
		description = opts.description,
		sections = opts.sections,
		session_id = vim.g.mdemg_session_id,
	}
	client.post("/v1/skills/" .. name .. "/register", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/skills/{name}/recall
function M.recall(name, callback)
	client.post("/v1/skills/" .. name .. "/recall", {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
