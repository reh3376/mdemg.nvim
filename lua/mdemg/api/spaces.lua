local M = {}
local client = require("mdemg.client")

-- GET /v1/admin/spaces
function M.list(callback)
	client.get("/v1/admin/spaces", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- PATCH /v1/admin/spaces/{space_id}
function M.update(space_id, opts, callback)
	opts = opts or {}
	local body = {
		prunable = opts.prunable,
		protected = opts.protected,
	}
	client.patch("/v1/admin/spaces/" .. space_id, body, {
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
	opts = opts or {}
	local body = {
		profile = opts.profile,
		obs_types = opts.obs_types,
	}
	client.post("/v1/admin/spaces/export", body, {
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
	opts = opts or {}
	local body = {
		target_space = opts.target_space,
	}
	client.post("/v1/admin/spaces/import", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/admin/spaces/prune
function M.prune(opts, callback)
	opts = opts or {}
	local body = {
		dry_run = opts.dry_run,
	}
	client.post("/v1/admin/spaces/prune", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/memory/freshness
function M.freshness_batch(space_ids, callback)
	local params_str = ""
	for _, sid in ipairs(space_ids) do
		if params_str ~= "" then
			params_str = params_str .. "&"
		end
		params_str = params_str .. "space_ids[]=" .. vim.uri_encode(sid)
	end
	local endpoint = vim.b.mdemg_endpoint or vim.g.mdemg_endpoint or require("mdemg.config").get().endpoint
	client.request("GET", "/v1/memory/freshness?" .. params_str, {
		endpoint = endpoint,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
