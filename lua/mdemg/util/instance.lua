local M = {}

M._cache = {}

function M.resolve(bufpath)
	if not bufpath or bufpath == "" then
		return nil
	end

	for root, info in pairs(M._cache) do
		if bufpath:sub(1, #root) == root then
			return info
		end
	end

	local dir = vim.fn.fnamemodify(bufpath, ":p:h")
	local project_root = nil

	while dir and dir ~= "/" and dir ~= "" do
		if vim.fn.isdirectory(dir .. "/.mdemg") == 1 then
			project_root = dir
			break
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end

	if not project_root then
		return nil
	end

	local endpoint = nil

	local port_file = project_root .. "/.mdemg.port"
	if vim.fn.filereadable(port_file) == 1 then
		local lines = vim.fn.readfile(port_file)
		if #lines > 0 then
			local port = vim.trim(lines[1])
			if tonumber(port) then
				endpoint = "http://localhost:" .. port
			end
		end
	end

	if not endpoint then
		local config_path = project_root .. "/.mdemg/config.yaml"
		local config_reader = require("mdemg.util.config_reader")
		local yaml = config_reader.read(config_path)
		if yaml and yaml.server and yaml.server.port then
			endpoint = "http://localhost:" .. yaml.server.port
		end
	end

	if not endpoint then
		local env = vim.env.MDEMG_ENDPOINT
		if env and env ~= "" then
			endpoint = env
		end
	end

	if not endpoint then
		endpoint = require("mdemg.config").get().endpoint
	end

	local info = {
		endpoint = endpoint,
		project_root = project_root,
	}

	M._cache[project_root] = info
	return info
end

function M.clear_cache()
	M._cache = {}
end

return M
