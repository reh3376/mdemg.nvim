describe("mdemg.util.config_reader", function()
	local config_reader

	before_each(function()
		package.loaded["mdemg.util.config_reader"] = nil
		config_reader = require("mdemg.util.config_reader")
	end)

	describe("_parse_value", function()
		it("parses 'true' as boolean true", function()
			assert.equals(true, config_reader._parse_value("true"))
		end)

		it("parses 'false' as boolean false", function()
			assert.equals(false, config_reader._parse_value("false"))
		end)

		it("parses 'null' as nil", function()
			assert.is_nil(config_reader._parse_value("null"))
		end)

		it("parses '~' as nil", function()
			assert.is_nil(config_reader._parse_value("~"))
		end)

		it("parses empty string as nil", function()
			assert.is_nil(config_reader._parse_value(""))
		end)

		it("parses integer string as number", function()
			assert.equals(42, config_reader._parse_value("42"))
		end)

		it("parses float string as number", function()
			assert.equals(3.14, config_reader._parse_value("3.14"))
		end)

		it("unquotes double-quoted string", function()
			assert.equals("hello", config_reader._parse_value('"hello"'))
		end)

		it("unquotes single-quoted string", function()
			assert.equals("world", config_reader._parse_value("'world'"))
		end)

		it("returns bare string as-is", function()
			assert.equals("bare_string", config_reader._parse_value("bare_string"))
		end)

		it("trims whitespace before parsing", function()
			assert.equals(true, config_reader._parse_value("  true  "))
		end)

		it("trims whitespace around numbers", function()
			assert.equals(99, config_reader._parse_value("  99  "))
		end)
	end)

	describe("read", function()
		it("returns nil for non-existent file", function()
			assert.is_nil(config_reader.read("/nonexistent/path.yaml"))
		end)

		it("parses simple yaml file via manual parser", function()
			local tmp = vim.fn.tempname()
			local f = io.open(tmp, "w")
			f:write("space_id: my-space\nserver:\n  port: 8080\n  host: localhost\n")
			f:close()

			-- Force manual parser by making yq unavailable
			local orig_executable = vim.fn.executable
			vim.fn.executable = function()
				return 0
			end

			local result = config_reader.read(tmp)

			vim.fn.executable = orig_executable
			os.remove(tmp)

			assert.equals("my-space", result.space_id)
			assert.equals(8080, result.server.port)
			assert.equals("localhost", result.server.host)
		end)

		it("skips comment lines", function()
			local tmp = vim.fn.tempname()
			local f = io.open(tmp, "w")
			f:write("# This is a comment\nkey: value\n  # Nested comment\n")
			f:close()

			local orig_executable = vim.fn.executable
			vim.fn.executable = function()
				return 0
			end

			local result = config_reader.read(tmp)

			vim.fn.executable = orig_executable
			os.remove(tmp)

			assert.equals("value", result.key)
		end)

		it("skips blank lines", function()
			local tmp = vim.fn.tempname()
			local f = io.open(tmp, "w")
			f:write("first: one\n\n\nsecond: two\n")
			f:close()

			local orig_executable = vim.fn.executable
			vim.fn.executable = function()
				return 0
			end

			local result = config_reader.read(tmp)

			vim.fn.executable = orig_executable
			os.remove(tmp)

			assert.equals("one", result.first)
			assert.equals("two", result.second)
		end)

		it("parses boolean and number values in yaml", function()
			local tmp = vim.fn.tempname()
			local f = io.open(tmp, "w")
			f:write("enabled: true\ncount: 42\ndisabled: false\n")
			f:close()

			local orig_executable = vim.fn.executable
			vim.fn.executable = function()
				return 0
			end

			local result = config_reader.read(tmp)

			vim.fn.executable = orig_executable
			os.remove(tmp)

			assert.equals(true, result.enabled)
			assert.equals(42, result.count)
			assert.equals(false, result.disabled)
		end)
	end)
end)
