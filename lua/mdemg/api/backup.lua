local M = {}
local client = require("mdemg.client")

-- POST /v1/backup/trigger
function M.trigger(opts, callback)
	opts = opts or {}
	local body = {
		type = opts.type or "full",
		space_ids = opts.space_ids,
	}
	client.post("/v1/backup/trigger", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/backup/status/{id}
function M.status(backup_id, callback)
	client.get("/v1/backup/status/" .. backup_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/backup/list
function M.list(opts, callback)
	opts = opts or {}
	client.get("/v1/backup/list", {
		params = opts.type and { type = opts.type } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/backup/manifest/{id}
function M.manifest(backup_id, callback)
	client.get("/v1/backup/manifest/" .. backup_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- DELETE /v1/backup/{id}
function M.delete(backup_id, callback)
	client.delete("/v1/backup/" .. backup_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/backup/restore
function M.restore(backup_id, target_space_id, callback)
	local body = {
		backup_id = backup_id,
		target_space_id = target_space_id,
	}
	client.post("/v1/backup/restore", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/backup/restore/status/{id}
function M.restore_status(restore_id, callback)
	client.get("/v1/backup/restore/status/" .. restore_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
