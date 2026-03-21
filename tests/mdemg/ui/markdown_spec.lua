describe("mdemg.ui.markdown", function()
	local markdown

	before_each(function()
		package.loaded["mdemg.ui.markdown"] = nil
		markdown = require("mdemg.ui.markdown")
	end)

	describe("format_results", function()
		it("returns empty table for empty results", function()
			local lines = markdown.format_results({})
			assert.same({}, lines)
		end)

		it("formats a result with all fields", function()
			local lines = markdown.format_results({
				{
					name = "TestNode",
					score = 0.875,
					path = "internal/api/handler.go",
					layer = "L2",
					summary = "A test summary.",
				},
			})
			assert.equals("## TestNode", lines[1])
			assert.equals("**Score:** 0.875", lines[2])
			assert.equals("**Path:** `internal/api/handler.go`", lines[3])
			assert.equals("**Layer:** L2", lines[4])
			-- blank line before summary
			assert.equals("", lines[5])
			assert.equals("A test summary.", lines[6])
		end)

		it("uses node_id when name is missing", function()
			local lines = markdown.format_results({
				{ node_id = "abc-123", score = 0.5 },
			})
			assert.equals("## abc-123", lines[1])
		end)

		it("uses 'Result N' when both name and node_id are missing", function()
			local lines = markdown.format_results({
				{ score = 0.5 },
			})
			assert.equals("## Result 1", lines[1])
		end)

		it("omits optional fields gracefully", function()
			local lines = markdown.format_results({
				{ name = "Minimal" },
			})
			assert.equals("## Minimal", lines[1])
			-- No score, path, layer, summary — just the separator
			assert.equals("", lines[2])
			assert.equals("---", lines[3])
		end)

		it("formats evidence entries", function()
			local lines = markdown.format_results({
				{
					name = "WithEvidence",
					evidence = {
						{
							symbol_name = "HandleRequest",
							symbol_type = "function",
							file_path = "api.go",
							line = 42,
						},
					},
				},
			})
			local found = false
			for _, line in ipairs(lines) do
				if line:match("HandleRequest") and line:match("function") and line:match("api.go:42") then
					found = true
					break
				end
			end
			assert.is_true(found)
		end)

		it("includes evidence header", function()
			local lines = markdown.format_results({
				{
					name = "Node",
					evidence = {
						{ symbol_name = "Fn", symbol_type = "func", file = "x.go" },
					},
				},
			})
			local has_header = false
			for _, line in ipairs(lines) do
				if line == "### Evidence" then
					has_header = true
					break
				end
			end
			assert.is_true(has_header)
		end)

		it("ends each result with separator", function()
			local lines = markdown.format_results({
				{ name = "First" },
				{ name = "Second" },
			})
			-- Find "---" separators
			local separators = 0
			for _, line in ipairs(lines) do
				if line == "---" then
					separators = separators + 1
				end
			end
			assert.equals(2, separators)
		end)
	end)

	describe("format_detail", function()
		it("formats full result with all fields", function()
			local lines = markdown.format_detail({
				name = "DetailNode",
				node_id = "node-456",
				score = 0.923,
				path = "internal/hidden/layer.go",
				layer = "L3",
				confidence_level = "high",
				summary = "Detailed summary here.",
			})
			assert.equals("# DetailNode", lines[1])
			-- Check node_id present
			local has_node_id = false
			for _, line in ipairs(lines) do
				if line:match("node%-456") then
					has_node_id = true
					break
				end
			end
			assert.is_true(has_node_id)
		end)

		it("uses 'Memory Node' as fallback title", function()
			local lines = markdown.format_detail({})
			assert.equals("# Memory Node", lines[1])
		end)

		it("includes summary section", function()
			local lines = markdown.format_detail({
				name = "Test",
				summary = "My summary text.",
			})
			local has_summary_header = false
			local has_summary_text = false
			for _, line in ipairs(lines) do
				if line == "## Summary" then
					has_summary_header = true
				end
				if line == "My summary text." then
					has_summary_text = true
				end
			end
			assert.is_true(has_summary_header)
			assert.is_true(has_summary_text)
		end)

		it("includes jiminy rationale section", function()
			local lines = markdown.format_detail({
				name = "Test",
				jiminy = { rationale = "Because reasons." },
			})
			local has_retrieval = false
			local has_rationale = false
			for _, line in ipairs(lines) do
				if line == "## Retrieval Details" then
					has_retrieval = true
				end
				if line == "Because reasons." then
					has_rationale = true
				end
			end
			assert.is_true(has_retrieval)
			assert.is_true(has_rationale)
		end)

		it("formats evidence with line_end range", function()
			local lines = markdown.format_detail({
				name = "Test",
				evidence = {
					{
						symbol_name = "Process",
						symbol_type = "method",
						file_path = "svc.go",
						line = 10,
						line_end = 25,
					},
				},
			})
			local has_range = false
			for _, line in ipairs(lines) do
				if line:match("svc.go:10%-25") then
					has_range = true
					break
				end
			end
			assert.is_true(has_range)
		end)

		it("formats evidence with signature", function()
			local lines = markdown.format_detail({
				name = "Test",
				evidence = {
					{
						symbol_name = "Run",
						symbol_type = "function",
						file_path = "main.go",
						line = 5,
						signature = "func Run(ctx context.Context) error",
					},
				},
			})
			local has_sig = false
			for _, line in ipairs(lines) do
				if line:match("Signature:") and line:match("func Run") then
					has_sig = true
					break
				end
			end
			assert.is_true(has_sig)
		end)

		it("uses 'unknown' for missing evidence fields", function()
			local lines = markdown.format_detail({
				name = "Test",
				evidence = { {} },
			})
			local has_unknown = false
			for _, line in ipairs(lines) do
				if line:match("### `unknown`") then
					has_unknown = true
					break
				end
			end
			assert.is_true(has_unknown)
		end)

		it("handles evidence with file fallback", function()
			local lines = markdown.format_detail({
				name = "Test",
				evidence = {
					{
						symbol_name = "Fn",
						symbol_type = "func",
						file = "fallback.go",
						line = 1,
					},
				},
			})
			local has_fallback = false
			for _, line in ipairs(lines) do
				if line:match("fallback.go:1") then
					has_fallback = true
					break
				end
			end
			assert.is_true(has_fallback)
		end)

		it("includes confidence level", function()
			local lines = markdown.format_detail({
				name = "Test",
				confidence_level = "medium",
			})
			local has_confidence = false
			for _, line in ipairs(lines) do
				if line == "**Confidence:** medium" then
					has_confidence = true
					break
				end
			end
			assert.is_true(has_confidence)
		end)
	end)
end)
