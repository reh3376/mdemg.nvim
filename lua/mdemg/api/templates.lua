local M = {}
local client = require("mdemg.client")

-- GET /v1/conversation/templates
function M.list(callback)
	client.get("/v1/conversation/templates", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/conversation/templates
function M.create(body, callback)
	client.post("/v1/conversation/templates", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/conversation/templates/{id}
function M.get(id, callback)
	client.get("/v1/conversation/templates/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- PUT /v1/conversation/templates/{id}
function M.update(id, body, callback)
	client.request("PUT", "/v1/conversation/templates/" .. id, {
		body = body,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- DELETE /v1/conversation/templates/{id}
function M.delete(id, callback)
	client.delete("/v1/conversation/templates/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
