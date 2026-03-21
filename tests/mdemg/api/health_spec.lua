describe("mdemg.api.health", function()
	local mod
	local captured_path, captured_method, captured_opts

	before_each(function()
		package.loaded["mdemg.api.health"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		vim.b.mdemg_space_id = "test-space"
		vim.g.mdemg_space_id = nil

		package.loaded["mdemg.client"] = {
			resolve_space_id = function()
				return "test-space"
			end,
			resolve_endpoint = function()
				return "http://localhost:9999"
			end,
			post = function(path, body, opts)
				captured_path = path
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
				captured_method = "PATCH"
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
			request = function(method, path, opts)
				captured_path = path
				captured_method = method
				captured_opts = opts
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		mod = require("mdemg.api.health")
	end)

	describe("readyz", function()
		it("calls correct endpoint", function()
			mod.readyz(function() end)
			assert.equals("/readyz", captured_path)
		end)

		it("uses GET method", function()
			mod.readyz(function() end)
			assert.equals("GET", captured_method)
		end)

		it("sets timeout to 5", function()
			mod.readyz(function() end)
			assert.equals(5, captured_opts.timeout)
		end)
	end)

	describe("healthz", function()
		it("calls correct endpoint", function()
			mod.healthz(function() end)
			assert.equals("/healthz", captured_path)
		end)

		it("sets timeout to 5", function()
			mod.healthz(function() end)
			assert.equals(5, captured_opts.timeout)
		end)
	end)

	describe("embedding_health", function()
		it("calls correct endpoint", function()
			mod.embedding_health(function() end)
			assert.equals("/v1/embedding/health", captured_path)
		end)
	end)

	describe("stats", function()
		it("calls correct endpoint", function()
			mod.stats(function() end)
			assert.equals("/v1/memory/stats", captured_path)
		end)

		it("passes space_id from vim.b", function()
			mod.stats(function() end)
			assert.equals("test-space", captured_opts.params.space_id)
		end)

		it("omits params when resolve_space_id returns nil", function()
			package.loaded["mdemg.client"].resolve_space_id = function()
				return nil
			end
			mod.stats(function() end)
			assert.is_nil(captured_opts.params)
		end)
	end)

	describe("freshness", function()
		it("calls correct endpoint with space_id", function()
			mod.freshness("my-space", function() end)
			assert.equals("/v1/memory/spaces/my-space/freshness", captured_path)
		end)

		it("returns error when no space_id available", function()
			package.loaded["mdemg.client"].resolve_space_id = function()
				return nil
			end
			local got_err
			mod.freshness(nil, function(err)
				got_err = err
			end)
			assert.equals("No space_id available", got_err)
		end)
	end)

	describe("freeze_status", function()
		it("calls correct endpoint", function()
			mod.freeze_status(function() end)
			assert.equals("/v1/learning/freeze/status", captured_path)
		end)

		it("passes space_id when available", function()
			mod.freeze_status(function() end)
			assert.equals("test-space", captured_opts.params.space_id)
		end)

		it("omits params when resolve_space_id returns nil", function()
			package.loaded["mdemg.client"].resolve_space_id = function()
				return nil
			end
			mod.freeze_status(function() end)
			assert.is_nil(captured_opts.params)
		end)
	end)
end)
