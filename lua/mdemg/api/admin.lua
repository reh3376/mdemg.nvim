local M = {}
local client = require("mdemg.client")

-- GET /v1/admin/spaces
function M.list_spaces(callback)
	client.get("/v1/admin/spaces", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/admin/spaces/{space_id}
function M.get_space(space_id, callback)
	client.get("/v1/admin/spaces/" .. space_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- PATCH /v1/admin/spaces/{space_id}
function M.update_space(space_id, opts, callback)
	client.patch("/v1/admin/spaces/" .. space_id, opts, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- DELETE /v1/admin/spaces/{space_id}
function M.delete_space(space_id, callback)
	client.delete("/v1/admin/spaces/" .. space_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/admin/spaces/prune
function M.prune_spaces(opts, callback)
	client.post("/v1/admin/spaces/prune", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/admin/spaces/export/preview
function M.export_preview(opts, callback)
	client.post("/v1/admin/spaces/export/preview", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/admin/spaces/export
function M.export(opts, callback)
	client.post("/v1/admin/spaces/export", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/admin/spaces/import
function M.import(opts, callback)
	client.post("/v1/admin/spaces/import", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/memory/meta-learn
function M.meta_learn(opts, callback)
	client.post("/v1/memory/meta-learn", opts or {}, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
