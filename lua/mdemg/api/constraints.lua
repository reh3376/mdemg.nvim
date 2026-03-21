local M = {}
local client = require("mdemg.client")

-- GET /v1/constraints
function M.list(callback)
	local space_id = require("mdemg.client").resolve_space_id()
	client.get("/v1/constraints", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/constraints/stats
function M.stats(callback)
	local space_id = require("mdemg.client").resolve_space_id()
	client.get("/v1/constraints/stats", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/constraints/effectiveness
function M.effectiveness(constraint_id, callback)
	local space_id = require("mdemg.client").resolve_space_id()
	local params = {}
	if space_id then
		params.space_id = space_id
	end
	if constraint_id then
		params.constraint_id = constraint_id
	end
	client.get("/v1/constraints/effectiveness", {
		params = params,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- PATCH /v1/constraints/scope/{id}
function M.set_scope(constraint_id, scope, callback)
	client.patch("/v1/constraints/scope/" .. constraint_id, { scope_override = scope }, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/constraints/detect-conflicts
function M.detect_conflicts(constraint_ids, callback)
	local body = { constraint_ids = constraint_ids }
	local space_id = require("mdemg.client").resolve_space_id()
	if space_id then
		body.space_id = space_id
	end
	client.post("/v1/constraints/detect-conflicts", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/constraints/conflicts
function M.conflicts(callback)
	local space_id = require("mdemg.client").resolve_space_id()
	client.get("/v1/constraints/conflicts", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- PATCH /v1/constraints/conflicts/{id}/resolve
function M.resolve_conflict(conflict_id, resolution, callback)
	client.patch("/v1/constraints/conflicts/" .. conflict_id .. "/resolve", { resolution = resolution }, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
