local M = {}
local client = require("mdemg.client")

-- POST /v1/hash-verification/register
function M.register(base_path, callback)
	local body = { base_path = base_path }
	client.post("/v1/hash-verification/register", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/hash-verification/files
function M.files(callback)
	local space_id = require("mdemg.client").resolve_space_id()
	client.get("/v1/hash-verification/files", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/hash-verification/files/{hash}
function M.get_by_hash(hash, callback)
	client.get("/v1/hash-verification/files/" .. hash, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/hash-verification/verify
function M.verify(file_path, callback)
	local body = { file_path = file_path }
	client.post("/v1/hash-verification/verify", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/hash-verification/verify-all
function M.verify_all(callback)
	client.post("/v1/hash-verification/verify-all", {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/hash-verification/update
function M.update(file_path, callback)
	local body = { file_path = file_path }
	client.post("/v1/hash-verification/update", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/hash-verification/revert
function M.revert(file_path, callback)
	local body = { file_path = file_path }
	client.post("/v1/hash-verification/revert", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/hash-verification/scan
function M.scan(base_path, callback)
	local body = { base_path = base_path }
	client.post("/v1/hash-verification/scan", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
