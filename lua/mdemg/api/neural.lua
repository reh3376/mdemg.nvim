local M = {}
local client = require("mdemg.client")

-- GET /v1/neural/status
function M.status(callback)
	client.get("/v1/neural/status", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
