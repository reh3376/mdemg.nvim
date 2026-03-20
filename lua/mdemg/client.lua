local M = {}

M._health = {}

local function resolve_endpoint()
	return vim.b.mdemg_endpoint or vim.g.mdemg_endpoint or require("mdemg.config").get().endpoint
end

local function resolve_space_id()
	return vim.b.mdemg_space_id or vim.g.mdemg_space_id or require("mdemg.config").get().space_id
end

function M.request(method, path, opts)
	opts = opts or {}
	local endpoint = opts.endpoint or resolve_endpoint()
	local url = endpoint .. path

	if opts.params then
		local parts = {}
		for k, v in pairs(opts.params) do
			table.insert(parts, vim.uri_encode(k) .. "=" .. vim.uri_encode(tostring(v)))
		end
		if #parts > 0 then
			url = url .. "?" .. table.concat(parts, "&")
		end
	end

	local args = { "curl", "-s", "-S", "-X", method, url }
	table.insert(args, "-H")
	table.insert(args, "Content-Type: application/json")
	table.insert(args, "--max-time")
	table.insert(args, tostring(opts.timeout or require("mdemg.config").get().timeout))

	if opts.body then
		local body = opts.body
		if type(body) == "table" then
			if body.space_id == nil then
				local sid = resolve_space_id()
				if sid then
					body.space_id = sid
				end
			end
			body = vim.json.encode(body)
		end
		table.insert(args, "-d")
		table.insert(args, body)
	end

	table.insert(args, "-w")
	table.insert(args, "\n%{http_code}")

	vim.system(args, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				M._track_failure(endpoint)
				local err_msg = result.stderr or "Connection failed"
				if err_msg:match("Connection refused") or err_msg:match("connect to host") then
					err_msg = "MDEMG instance not running — run `mdemg start` in project root"
				elseif err_msg:match("timed out") or err_msg:match("Operation timed out") then
					err_msg = "Request timed out after "
						.. (opts.timeout or require("mdemg.config").get().timeout)
						.. "s"
				end
				if opts.on_error then
					opts.on_error(err_msg)
				end
				return
			end

			local output = result.stdout or ""
			local lines = vim.split(output, "\n")
			local status_code = tonumber(lines[#lines]) or 0
			table.remove(lines, #lines)
			local body_str = table.concat(lines, "\n")

			if status_code >= 200 and status_code < 500 then
				M._track_success(endpoint)
			else
				M._track_failure(endpoint)
			end

			local ok_decode, decoded = pcall(vim.json.decode, body_str)
			if not ok_decode then
				decoded = nil
			end

			if status_code >= 200 and status_code < 300 then
				if opts.on_success then
					opts.on_success(status_code, decoded or body_str)
				end
			else
				local err_msg = "HTTP " .. status_code
				if decoded and decoded.error then
					err_msg = decoded.error
				elseif decoded and decoded.message then
					err_msg = decoded.message
				end
				if opts.on_error then
					opts.on_error(err_msg)
				end
			end
		end)
	end)
end

function M.get(path, opts)
	M.request("GET", path, opts)
end

function M.post(path, body, opts)
	opts = opts or {}
	opts.body = body
	M.request("POST", path, opts)
end

function M.patch(path, body, opts)
	opts = opts or {}
	opts.body = body
	M.request("PATCH", path, opts)
end

function M.delete(path, opts)
	M.request("DELETE", path, opts)
end

function M._track_success(endpoint)
	if not M._health[endpoint] then
		M._health[endpoint] = { failures = 0, healthy = true }
	end
	M._health[endpoint].failures = 0
	M._health[endpoint].healthy = true
end

function M._track_failure(endpoint)
	if not M._health[endpoint] then
		M._health[endpoint] = { failures = 0, healthy = true }
	end
	M._health[endpoint].failures = M._health[endpoint].failures + 1
	if M._health[endpoint].failures >= 3 then
		M._health[endpoint].healthy = false
	end
end

function M.is_healthy(endpoint)
	endpoint = endpoint or resolve_endpoint()
	local h = M._health[endpoint]
	return h == nil or h.healthy
end

function M.set_health(endpoint, healthy)
	if not M._health[endpoint] then
		M._health[endpoint] = { failures = 0, healthy = true }
	end
	M._health[endpoint].healthy = healthy
	if healthy then
		M._health[endpoint].failures = 0
	end
end

return M
