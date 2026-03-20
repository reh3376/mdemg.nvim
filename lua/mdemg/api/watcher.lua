local M = {}
local client = require("mdemg.client")

-- POST /v1/filewatcher/start
function M.start(opts, callback)
	client.post("/v1/filewatcher/start", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/filewatcher/status
function M.status(callback)
	client.get("/v1/filewatcher/status", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/filewatcher/stop
function M.stop(callback)
	client.post("/v1/filewatcher/stop", {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
