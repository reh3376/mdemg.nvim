local M = {}

function M.run(opts)
	opts = opts or {}
	local query = opts.query

	if opts.visual then
		vim.cmd('normal! "vy')
		query = vim.fn.getreg("v")
	end

	if opts.symbols then
		M._symbol_search(query)
		return
	end

	if not query or query == "" then
		vim.ui.input({ prompt = "MDEMG Recall: " }, function(input)
			if input and input ~= "" then
				M._execute_recall(input, opts)
			end
		end)
		return
	end

	M._execute_recall(query, opts)
end

function M._execute_recall(query, opts)
	local notify = require("mdemg.ui.notify")
	local api = require("mdemg.api.memory")
	local picker = require("mdemg.ui.picker")
	local markdown = require("mdemg.ui.markdown")
	local float = require("mdemg.ui.float")

	notify.info("Searching: " .. query)
	api.retrieve(query, {
		top_k = opts.top_k or 10,
		include_evidence = true,
	}, function(err, data)
		if err then
			notify.error("Recall failed: " .. err)
			return
		end
		if not data or not data.results or #data.results == 0 then
			notify.warn("No results found for: " .. query)
			return
		end

		picker.pick(data.results, {
			prompt = "MDEMG Recall: " .. query,
			format_item = function(item)
				local score = item.score and string.format("%.2f", item.score) or "?"
				return string.format("[%s] %s — %s", score, item.name or item.node_id or "?", item.summary or "")
			end,
			preview = function(item)
				return markdown.format_detail(item)
			end,
			on_select = function(item)
				local detail_lines = markdown.format_detail(item)
				float.open({
					title = item.name or "Memory Detail",
					content = detail_lines,
					filetype = "markdown",
					modifiable = false,
					keymaps = {
						["<CR>"] = function()
							local text = item.summary or item.name or ""
							vim.fn.setreg("+", text)
							notify.info("Copied to clipboard")
						end,
					},
				})
			end,
		})
	end)
end

function M._symbol_search(query)
	if not query or query == "" then
		vim.ui.input({ prompt = "Symbol Search: " }, function(input)
			if input and input ~= "" then
				M._execute_symbol_search(input)
			end
		end)
		return
	end
	M._execute_symbol_search(query)
end

function M._execute_symbol_search(query)
	local notify = require("mdemg.ui.notify")
	local symbols = require("mdemg.api.symbols")
	local picker = require("mdemg.ui.picker")

	symbols.search(query, {}, function(err, data)
		if err then
			notify.error("Symbol search failed: " .. err)
			return
		end
		if not data or not data.results or #data.results == 0 then
			notify.warn("No symbols found for: " .. query)
			return
		end
		picker.pick(data.results, {
			prompt = "Symbols: " .. query,
			format_item = function(item)
				return string.format(
					"%s (%s) — %s:%d",
					item.symbol_name or "?",
					item.symbol_type or "?",
					item.file or "?",
					item.line or 0
				)
			end,
			on_select = function(item)
				if item.file then
					vim.cmd("edit " .. item.file)
					if item.line then
						vim.api.nvim_win_set_cursor(0, { item.line, 0 })
					end
				end
			end,
		})
	end)
end

return M
