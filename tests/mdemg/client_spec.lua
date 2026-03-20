describe("mdemg.client", function()
	local client
	local captured_args

	before_each(function()
		package.loaded["mdemg.client"] = nil
		package.loaded["mdemg.config"] = nil

		local config = require("mdemg.config")
		config.setup({ endpoint = "http://localhost:9999" })

		captured_args = nil
		local mock_result = { code = 0, stdout = '{"ok":true}\n200', stderr = "" }

		vim.system = function(args, _, callback)
			captured_args = args
			if callback then
				vim.schedule(function()
					callback(mock_result)
				end)
			end
			return {
				wait = function()
					return mock_result
				end,
			}
		end

		client = require("mdemg.client")
	end)

	describe("request", function()
		it("constructs correct curl args for GET", function()
			client.get("/readyz", {
				on_success = function() end,
			})
			assert.is_not_nil(captured_args)
			assert.equals("curl", captured_args[1])
			local has_get = false
			local has_url = false
			for _, v in ipairs(captured_args) do
				if v == "GET" then
					has_get = true
				end
				if v == "http://localhost:9999/readyz" then
					has_url = true
				end
			end
			assert.is_true(has_get)
			assert.is_true(has_url)
		end)

		it("constructs correct curl args for POST with body", function()
			client.post("/v1/memory/retrieve", { query_text = "test" }, {
				on_success = function() end,
			})
			assert.is_not_nil(captured_args)
			local has_post = false
			for _, v in ipairs(captured_args) do
				if v == "POST" then
					has_post = true
				end
			end
			assert.is_true(has_post)
			local body_idx = nil
			for i, v in ipairs(captured_args) do
				if v == "-d" then
					body_idx = i + 1
					break
				end
			end
			assert.is_not_nil(body_idx)
			local body = vim.json.decode(captured_args[body_idx])
			assert.equals("test", body.query_text)
		end)

		it("includes query params in URL", function()
			client.get("/v1/memory/stats", {
				params = { space_id = "test-space" },
				on_success = function() end,
			})
			assert.is_not_nil(captured_args)
			local url = nil
			for _, v in ipairs(captured_args) do
				if v:match("^http") then
					url = v
					break
				end
			end
			assert.is_truthy(url:match("space_id=test%-space"))
		end)
	end)

	describe("health tracking", function()
		it("starts healthy", function()
			assert.is_true(client.is_healthy("http://localhost:9999"))
		end)

		it("marks unhealthy after 3 failures", function()
			client._track_failure("http://test:1234")
			client._track_failure("http://test:1234")
			assert.is_true(client.is_healthy("http://test:1234"))
			client._track_failure("http://test:1234")
			assert.is_false(client.is_healthy("http://test:1234"))
		end)

		it("resets on success", function()
			client._track_failure("http://test:1234")
			client._track_failure("http://test:1234")
			client._track_failure("http://test:1234")
			assert.is_false(client.is_healthy("http://test:1234"))
			client._track_success("http://test:1234")
			assert.is_true(client.is_healthy("http://test:1234"))
		end)
	end)
end)
