describe("mdemg.api.memory", function()
	local memory
	local captured_path, captured_body

	before_each(function()
		package.loaded["mdemg.api.memory"] = nil
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		package.loaded["mdemg.client"] = {
			post = function(path, body, opts)
				captured_path = path
				captured_body = body
				if opts.on_success then
					opts.on_success(200, { results = {} })
				end
			end,
			get = function(path, opts)
				captured_path = path
				if opts.on_success then
					opts.on_success(200, {})
				end
			end,
		}

		memory = require("mdemg.api.memory")
	end)

	describe("retrieve", function()
		it("calls correct endpoint", function()
			memory.retrieve("test query", {}, function() end)
			assert.equals("/v1/memory/retrieve", captured_path)
		end)

		it("passes query_text in body", function()
			memory.retrieve("find something", {}, function() end)
			assert.equals("find something", captured_body.query_text)
		end)

		it("passes top_k option", function()
			memory.retrieve("test", { top_k = 5 }, function() end)
			assert.equals(5, captured_body.top_k)
		end)

		it("defaults top_k to 10", function()
			memory.retrieve("test", {}, function() end)
			assert.equals(10, captured_body.top_k)
		end)
	end)

	describe("ingest", function()
		it("calls correct endpoint", function()
			memory.ingest("some content", {}, function() end)
			assert.equals("/v1/memory/ingest", captured_path)
		end)

		it("includes timestamp", function()
			memory.ingest("content", {}, function() end)
			assert.is_not_nil(captured_body.timestamp)
		end)

		it("uses default source", function()
			memory.ingest("content", {}, function() end)
			assert.equals("neovim-observation", captured_body.source)
		end)

		it("allows custom source", function()
			memory.ingest("content", { source = "custom" }, function() end)
			assert.equals("custom", captured_body.source)
		end)
	end)

	describe("ingest_files", function()
		it("calls correct endpoint", function()
			memory.ingest_files({ "file1.go", "file2.go" }, function() end)
			assert.equals("/v1/memory/ingest/files", captured_path)
		end)

		it("passes file paths", function()
			memory.ingest_files({ "a.go", "b.py" }, function() end)
			assert.same({ "a.go", "b.py" }, captured_body.files)
		end)
	end)

	describe("validate", function()
		it("calls correct endpoint", function()
			memory.validate("diff content", { "file.go" }, function() end)
			assert.equals("/v1/memory/guardrail/validate", captured_path)
		end)

		it("passes diff and files", function()
			memory.validate("the diff", { "a.go", "b.go" }, function() end)
			assert.equals("the diff", captured_body.diff)
			assert.same({ "a.go", "b.go" }, captured_body.files_changed)
		end)
	end)
end)
