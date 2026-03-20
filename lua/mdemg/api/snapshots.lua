local M = {}
local client = require("mdemg.client")

-- GET /v1/conversation/snapshot
function M.list(callback)
	client.get("/v1/conversation/snapshot", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/conversation/snapshot
function M.create(opts, callback)
	client.post("/v1/conversation/snapshot", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/conversation/snapshot/{id}
function M.get(id, callback)
	client.get("/v1/conversation/snapshot/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/conversation/snapshot/latest
function M.latest(callback)
	client.get("/v1/conversation/snapshot/latest", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- DELETE /v1/conversation/snapshot/{id}
function M.delete(id, callback)
	client.delete("/v1/conversation/snapshot/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/conversation/snapshot/cleanup
function M.cleanup(callback)
	client.post("/v1/conversation/snapshot/cleanup", {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
