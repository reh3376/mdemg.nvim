local M = {}
local client = require("mdemg.client")

-- POST /v1/webhooks/linear
function M.linear(body, callback)
	client.post("/v1/webhooks/linear", body or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/webhooks/{id}
function M.trigger(id, body, callback)
	client.post("/v1/webhooks/" .. id, body or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
