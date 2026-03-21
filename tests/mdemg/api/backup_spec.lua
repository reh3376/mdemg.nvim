describe("mdemg.api.backup", function()
	local mod
	local captured_path, captured_body, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.backup"] = nil
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

		mod = require("mdemg.api.backup")
	end)

	describe("trigger", function()
		it("calls correct endpoint", function()
			mod.trigger({}, function() end)
			assert.equals("/v1/backup/trigger", captured_path)
		end)

		it("uses POST method", function()
			mod.trigger({}, function() end)
			assert.equals("POST", captured_method)
		end)

		it("defaults type to full", function()
			mod.trigger({}, function() end)
			assert.equals("full", captured_body.type)
		end)

		it("passes space_ids in body", function()
			mod.trigger({ space_ids = { "a", "b" } }, function() end)
			assert.same({ "a", "b" }, captured_body.space_ids)
		end)
	end)

	describe("status", function()
		it("calls correct endpoint with backup_id", function()
			mod.status("bk-001", function() end)
			assert.equals("/v1/backup/status/bk-001", captured_path)
		end)
	end)

	describe("list", function()
		it("calls correct endpoint", function()
			mod.list({}, function() end)
			assert.equals("/v1/backup/list", captured_path)
		end)

		it("passes type filter in params", function()
			mod.list({ type = "incremental" }, function() end)
			assert.equals("incremental", captured_opts.params.type)
		end)

		it("omits params when no type set", function()
			mod.list({}, function() end)
			assert.is_nil(captured_opts.params)
		end)
	end)

	describe("manifest", function()
		it("calls correct endpoint with backup_id", function()
			mod.manifest("bk-002", function() end)
			assert.equals("/v1/backup/manifest/bk-002", captured_path)
		end)
	end)

	describe("delete", function()
		it("calls correct endpoint with backup_id", function()
			mod.delete("bk-003", function() end)
			assert.equals("/v1/backup/bk-003", captured_path)
		end)

		it("uses DELETE method", function()
			mod.delete("bk-003", function() end)
			assert.equals("DELETE", captured_method)
		end)
	end)

	describe("restore", function()
		it("calls correct endpoint", function()
			mod.restore("bk-004", "target-space", function() end)
			assert.equals("/v1/backup/restore", captured_path)
		end)

		it("passes backup_id and target_space_id in body", function()
			mod.restore("bk-005", "dest-space", function() end)
			assert.equals("bk-005", captured_body.backup_id)
			assert.equals("dest-space", captured_body.target_space_id)
		end)
	end)

	describe("restore_status", function()
		it("calls correct endpoint with restore_id", function()
			mod.restore_status("rs-001", function() end)
			assert.equals("/v1/backup/restore/status/rs-001", captured_path)
		end)
	end)
end)
