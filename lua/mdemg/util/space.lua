local M = {}

-- Cache stores { [project_root] = { value = "space_id", mtime = number } }
M._cache = {}

function M.resolve(project_root)
	if not project_root then
		return nil
	end

	local config_path = project_root .. "/.mdemg/config.yaml"
	local current_mtime = vim.fn.getftime(config_path)

	local cached = M._cache[project_root]
	if cached and cached.mtime == current_mtime then
		return cached.value
	end

	local space_id = nil

	local config_reader = require("mdemg.util.config_reader")
	local yaml = config_reader.read(config_path)
	if yaml then
		if yaml.space_id then
			space_id = yaml.space_id
		elseif yaml.space and type(yaml.space) == "table" and yaml.space.id then
			space_id = yaml.space.id
		end
	end

	if not space_id then
		local env = vim.env.MDEMG_SPACE_ID
		if env and env ~= "" then
			space_id = env
		end
	end

	if not space_id then
		local cfg_space = require("mdemg.config").get().space_id
		if cfg_space then
			space_id = cfg_space
		end
	end

	if not space_id then
		vim.notify(
			"[mdemg] No space_id found for "
				.. project_root
				.. " — set space_id in .mdemg/config.yaml, MDEMG_SPACE_ID env, or setup({space_id = '...'})",
			vim.log.levels.WARN,
			{ once = true }
		)
	end

	-- Only cache non-nil values so re-resolution works after user fixes config
	if space_id then
		M._cache[project_root] = { value = space_id, mtime = current_mtime }
	end
	return space_id
end

function M.clear_cache()
	M._cache = {}
end

return M
