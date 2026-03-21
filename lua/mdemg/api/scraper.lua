local M = {}
local client = require("mdemg.client")

-- POST /v1/scraper/jobs
function M.create(urls, target_space_id, callback)
	local body = {
		urls = urls,
		target_space_id = target_space_id,
	}
	client.post("/v1/scraper/jobs", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/scraper/jobs
function M.list(opts, callback)
	opts = opts or {}
	local params = {}
	if opts.status then
		params.status = opts.status
	end
	local space_id = opts.space_id or require("mdemg.client").resolve_space_id()
	if space_id then
		params.space_id = space_id
	end
	client.get("/v1/scraper/jobs", {
		params = next(params) and params or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/scraper/jobs/{id}
function M.get(job_id, callback)
	client.get("/v1/scraper/jobs/" .. job_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- DELETE /v1/scraper/jobs/{id}
function M.cancel(job_id, callback)
	client.delete("/v1/scraper/jobs/" .. job_id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/scraper/jobs/{id}/review
function M.review(job_id, reviewed, notes, callback)
	local body = {
		reviewed = reviewed,
		notes = notes,
	}
	client.post("/v1/scraper/jobs/" .. job_id .. "/review", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/scraper/spaces
function M.spaces(callback)
	client.get("/v1/scraper/spaces", {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
