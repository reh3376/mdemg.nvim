local M = {}
local client = require("mdemg.client")

function M.readyz(callback)
	client.get("/readyz", {
		on_success = function(status)
			callback(nil, status)
		end,
		on_error = function(err)
			callback(err)
		end,
		timeout = 5,
	})
end

function M.healthz(callback)
	client.get("/healthz", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
		timeout = 5,
	})
end

function M.embedding_health(callback)
	client.get("/v1/embedding/health", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.stats(callback)
	local space_id = require("mdemg.client").resolve_space_id()
	client.get("/v1/memory/stats", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.freshness(space_id, callback)
	space_id = space_id or require("mdemg.client").resolve_space_id()
	if not space_id then
		callback("No space_id available")
		return
	end
	client.get("/v1/memory/spaces/" .. space_id .. "/freshness", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.freeze_status(callback)
	local space_id = require("mdemg.client").resolve_space_id()
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

return M
