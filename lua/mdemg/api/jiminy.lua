local M = {}
local client = require("mdemg.client")

function M.guide(context, opts, callback)
	opts = opts or {}
	local body = {
		context = context,
		file_path = opts.file_path,
		agent_output = opts.agent_output,
		query = opts.query,
		session_id = opts.session_id or vim.g.mdemg_session_id,
		max_items = opts.max_items or 5,
	}
	client.post("/v1/jiminy/guide", body, {
		on_success = function(_, data)
			if data and data.data then
				callback(nil, data.data)
			else
				callback(nil, data)
			end
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.feedback(guidance_id, helpful, opts, callback)
	opts = opts or {}
	local body = {
		guidance_id = guidance_id,
		helpful = helpful,
		feedback = opts.feedback,
		applied = opts.applied,
	}
	client.post("/v1/jiminy/feedback", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
