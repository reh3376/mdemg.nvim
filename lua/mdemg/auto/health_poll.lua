local M = {}

M._timer = nil
M._stats_timer = nil

function M.setup()
	local cfg = require("mdemg.config").get()

	local interval = (cfg.auto.health_poll_interval or 30) * 1000
	M._timer = vim.uv.new_timer()
	M._timer:start(1000, interval, vim.schedule_wrap(function()
		M._check_health()
	end))

	local stats_interval = (cfg.auto.stats_refresh_interval or 120) * 1000
	M._stats_timer = vim.uv.new_timer()
	M._stats_timer:start(5000, stats_interval, vim.schedule_wrap(function()
		M._refresh_stats()
	end))
end

function M._check_health()
	local health = require("mdemg.api.health")
	local statusline = require("mdemg.ui.statusline")

	health.readyz(function(err)
		local connected = err == nil
		statusline.update_state({ connected = connected, last_check = os.time() })
	end)
end

function M._refresh_stats()
	local health = require("mdemg.api.health")
	local statusline = require("mdemg.ui.statusline")

	health.stats(function(err, data)
		if err or not data then
			return
		end
		statusline.update_state({
			node_count = data.memory_count,
			health_score = data.health_score,
			space_id = data.space_id,
		})
	end)

	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	if space_id then
		health.freshness(space_id, function(err, data)
			if err or not data then
				return
			end
			statusline.update_state({ freshness = data })
		end)
	end
end

function M.stop()
	if M._timer then
		M._timer:stop()
		M._timer:close()
		M._timer = nil
	end
	if M._stats_timer then
		M._stats_timer:stop()
		M._stats_timer:close()
		M._stats_timer = nil
	end
end

return M
