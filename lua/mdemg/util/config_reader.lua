local M = {}

function M.read(path)
	if vim.fn.filereadable(path) == 0 then
		return nil
	end

	if vim.fn.executable("yq") == 1 then
		local result = vim.fn.system({ "yq", "-o=json", path })
		if vim.v.shell_error == 0 then
			local ok, parsed = pcall(vim.json.decode, result)
			if ok then
				return parsed
			end
		end
	end

	local config = {}
	local current_section = nil
	for line in io.lines(path) do
		if not line:match("^%s*#") and not line:match("^%s*$") then
			local top_key, top_val = line:match("^(%w[%w_]*):%s*(.*)")
			if top_key then
				if top_val and top_val ~= "" then
					config[top_key] = M._parse_value(top_val)
					current_section = nil
				else
					config[top_key] = {}
					current_section = top_key
				end
			else
				local nested_key, nested_val = line:match("^%s+(%w[%w_]*):%s*(.*)")
				if nested_key and current_section then
					if type(config[current_section]) ~= "table" then
						config[current_section] = {}
					end
					config[current_section][nested_key] = M._parse_value(nested_val or "")
				end
			end
		end
	end
	return config
end

function M._parse_value(val)
	val = vim.trim(val)
	if val == "true" then
		return true
	end
	if val == "false" then
		return false
	end
	if val == "null" or val == "~" or val == "" then
		return nil
	end
	local num = tonumber(val)
	if num then
		return num
	end
	local quoted = val:match('^"(.*)"$') or val:match("^'(.*)'$")
	if quoted then
		return quoted
	end
	return val
end

return M
