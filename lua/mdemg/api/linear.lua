local M = {}
local client = require("mdemg.client")

-- GET /v1/linear/issues
function M.list_issues(opts, callback)
	client.get("/v1/linear/issues", {
		params = opts,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/linear/issues/{id}
function M.get_issue(id, callback)
	client.get("/v1/linear/issues/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/linear/issues
function M.create_issue(body, callback)
	client.post("/v1/linear/issues", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- PUT /v1/linear/issues/{id}
function M.update_issue(id, body, callback)
	client.request("PUT", "/v1/linear/issues/" .. id, {
		body = body,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- DELETE /v1/linear/issues/{id}
function M.delete_issue(id, callback)
	client.delete("/v1/linear/issues/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/linear/projects
function M.list_projects(opts, callback)
	client.get("/v1/linear/projects", {
		params = opts,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/linear/projects/{id}
function M.get_project(id, callback)
	client.get("/v1/linear/projects/" .. id, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- GET /v1/linear/comments
function M.list_comments(opts, callback)
	client.get("/v1/linear/comments", {
		params = opts,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

-- POST /v1/linear/comments
function M.create_comment(body, callback)
	client.post("/v1/linear/comments", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
