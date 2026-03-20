local M = {}
local client = require("mdemg.client")

-- GET /v1/conversation/org-reviews
function M.list(callback)
	client.get("/v1/conversation/org-reviews", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/conversation/org-reviews/stats
function M.stats(callback)
	client.get("/v1/conversation/org-reviews/stats", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- PATCH /v1/conversation/org-reviews/{id}/decide
function M.decide(id, decision, callback)
	client.patch("/v1/conversation/org-reviews/" .. id .. "/decide", { decision = decision }, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/conversation/observations/{id}/flag
function M.flag(observation_id, reason, callback)
	client.post("/v1/conversation/observations/" .. observation_id .. "/flag", { reason = reason }, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
