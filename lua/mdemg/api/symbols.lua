local M = {}
local client = require("mdemg.client")

function M.search(query, opts, callback)
	opts = opts or {}
	local params = {
		query = query,
	}
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	if space_id then
		params.space_id = space_id
	end
	if opts.type then
		params.type = opts.type
	end
	if opts.exported ~= nil then
		params.exported = tostring(opts.exported)
	end
	if opts.limit then
		params.limit = tostring(opts.limit)
	end

	client.get("/v1/memory/symbols", {
		params = params,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
