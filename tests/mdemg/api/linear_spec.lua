describe("mdemg.api.linear", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.linear"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		package.loaded["mdemg.client"] = {
			resolve_space_id = function() return "test-space" end,
			resolve_endpoint = function() return "http://localhost:9999" end,
			post = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "POST"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			get = function(path, opts)
				captured_path = path
				captured_method = "GET"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			delete = function(path, opts)
				captured_path = path
				captured_method = "DELETE"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			patch = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "PATCH"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			request = function(method, path, opts)
				captured_path = path
				captured_method = method
				captured_body = opts.body
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		mod = require("mdemg.api.linear")
	end)

	describe("list_issues", function()
		it("calls correct endpoint", function()
			mod.list_issues({}, function() end)
			assert.equals("/v1/linear/issues", captured_path)
			assert.equals("GET", captured_method)
		end)

		it("passes opts as params", function()
			mod.list_issues({ status = "open", team = "eng" }, function() end)
			assert.equals("open", captured_opts.params.status)
			assert.equals("eng", captured_opts.params.team)
		end)
	end)

	describe("get_issue", function()
		it("calls correct endpoint with id", function()
			mod.get_issue("ISS-123", function() end)
			assert.equals("/v1/linear/issues/ISS-123", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("create_issue", function()
		it("calls correct endpoint", function()
			mod.create_issue({ title = "Bug" }, function() end)
			assert.equals("/v1/linear/issues", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes body through", function()
			mod.create_issue({ title = "New feature", priority = 1 }, function() end)
			assert.equals("New feature", captured_body.title)
			assert.equals(1, captured_body.priority)
		end)
	end)

	describe("update_issue", function()
		it("calls correct endpoint with id via client.request", function()
			mod.update_issue("ISS-456", { title = "Updated" }, function() end)
			assert.equals("/v1/linear/issues/ISS-456", captured_path)
			assert.equals("PUT", captured_method)
		end)

		it("passes body via opts.body", function()
			mod.update_issue("ISS-456", { status = "done" }, function() end)
			assert.equals("done", captured_body.status)
		end)
	end)

	describe("delete_issue", function()
		it("calls DELETE with id", function()
			mod.delete_issue("ISS-789", function() end)
			assert.equals("/v1/linear/issues/ISS-789", captured_path)
			assert.equals("DELETE", captured_method)
		end)
	end)

	describe("list_projects", function()
		it("calls correct endpoint", function()
			mod.list_projects({}, function() end)
			assert.equals("/v1/linear/projects", captured_path)
			assert.equals("GET", captured_method)
		end)

		it("passes opts as params", function()
			mod.list_projects({ state = "active" }, function() end)
			assert.equals("active", captured_opts.params.state)
		end)
	end)

	describe("get_project", function()
		it("calls correct endpoint with id", function()
			mod.get_project("PRJ-001", function() end)
			assert.equals("/v1/linear/projects/PRJ-001", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("list_comments", function()
		it("calls correct endpoint", function()
			mod.list_comments({}, function() end)
			assert.equals("/v1/linear/comments", captured_path)
			assert.equals("GET", captured_method)
		end)

		it("passes opts as params", function()
			mod.list_comments({ issue_id = "ISS-123" }, function() end)
			assert.equals("ISS-123", captured_opts.params.issue_id)
		end)
	end)

	describe("create_comment", function()
		it("calls correct endpoint", function()
			mod.create_comment({ body = "LGTM" }, function() end)
			assert.equals("/v1/linear/comments", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes body through", function()
			mod.create_comment({ body = "Needs review", issue_id = "ISS-123" }, function() end)
			assert.equals("Needs review", captured_body.body)
			assert.equals("ISS-123", captured_body.issue_id)
		end)
	end)
end)
