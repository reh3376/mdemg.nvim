describe("mdemg.api.hash", function()
	local hash
	local captured_path, captured_body, captured_method

	before_each(function()
		package.loaded["mdemg.api.hash"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		package.loaded["mdemg.client"] = {
			resolve_space_id = function()
				return "test-space"
			end,
			resolve_endpoint = function()
				return "http://localhost:9999"
			end,
			post = function(path, body, opts)
				captured_path = path
				captured_body = body
				captured_method = "POST"
				if opts.on_success then
					opts.on_success(200, { verified = true })
				end
			end,
			get = function(path, opts)
				captured_path = path
				captured_method = "GET"
				if opts.on_success then
					opts.on_success(200, { files = {} })
				end
			end,
		}

		hash = require("mdemg.api.hash")
	end)

	describe("register", function()
		it("calls correct endpoint", function()
			hash.register("/project", function() end)
			assert.equals("/v1/hash-verification/register", captured_path)
			assert.equals("POST", captured_method)
		end)

		it("passes base_path", function()
			hash.register("/my/project", function() end)
			assert.equals("/my/project", captured_body.base_path)
		end)
	end)

	describe("files", function()
		it("calls correct endpoint", function()
			hash.files(function() end)
			assert.equals("/v1/hash-verification/files", captured_path)
			assert.equals("GET", captured_method)
		end)
	end)

	describe("get_by_hash", function()
		it("includes hash in path", function()
			hash.get_by_hash("abc123", function() end)
			assert.equals("/v1/hash-verification/files/abc123", captured_path)
		end)
	end)

	describe("verify", function()
		it("calls correct endpoint", function()
			hash.verify("/path/to/file.go", function() end)
			assert.equals("/v1/hash-verification/verify", captured_path)
		end)

		it("passes file_path", function()
			hash.verify("/src/main.go", function() end)
			assert.equals("/src/main.go", captured_body.file_path)
		end)
	end)

	describe("verify_all", function()
		it("calls correct endpoint", function()
			hash.verify_all(function() end)
			assert.equals("/v1/hash-verification/verify-all", captured_path)
			assert.equals("POST", captured_method)
		end)
	end)

	describe("update", function()
		it("calls correct endpoint", function()
			hash.update("/file.go", function() end)
			assert.equals("/v1/hash-verification/update", captured_path)
		end)
	end)

	describe("scan", function()
		it("calls correct endpoint", function()
			hash.scan("/project", function() end)
			assert.equals("/v1/hash-verification/scan", captured_path)
		end)

		it("passes base_path", function()
			hash.scan("/my/dir", function() end)
			assert.equals("/my/dir", captured_body.base_path)
		end)
	end)
end)
