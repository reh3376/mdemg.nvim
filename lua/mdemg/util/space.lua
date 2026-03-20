local M = {}

M._cache = {}

function M.resolve(project_root)
	if not project_root then
		return nil
	end

	if M._cache[project_root] then
		return M._cache[project_root]
	end

	local space_id = nil

	local config_path = project_root .. "/.mdemg/config.yaml"
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
		space_id = vim.fn.fnamemodify(project_root, ":t")
	end

	M._cache[project_root] = space_id
	return space_id
end

function M.clear_cache()
	M._cache = {}
end

return M
