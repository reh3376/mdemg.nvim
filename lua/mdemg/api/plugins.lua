local M = {}
local client = require("mdemg.client")

-- GET /v1/plugins
function M.list(callback)
	client.get("/v1/plugins", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/plugins/{id}
function M.get(id, callback)
	client.get("/v1/plugins/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/modules
function M.list_modules(callback)
	client.get("/v1/modules", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/modules/{id}
function M.get_module(id, callback)
	client.get("/v1/modules/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/ape/status
function M.ape_status(callback)
	client.get("/v1/ape/status", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/plugins/create
function M.create(opts, callback)
	client.post("/v1/plugins/create", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/plugins/{id}/validate
function M.validate(id, callback)
	client.post("/v1/plugins/" .. id .. "/validate", {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/ape/trigger
function M.ape_trigger(opts, callback)
	client.post("/v1/ape/trigger", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
