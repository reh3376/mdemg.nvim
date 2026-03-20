local M = {}

function M.get_context()
	local result = {
		function_name = nil,
		class_name = nil,
		module_name = nil,
		filetype = vim.bo.filetype,
		filename = vim.fn.expand("%:t"),
	}

	local ok, parsers = pcall(require, "nvim-treesitter.parsers")
	if not ok then
		return result
	end

	local parser = parsers.get_parser()
	if not parser then
		return result
	end

	local tree = parser:parse()
	if not tree or not tree[1] then
		return result
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1

	local root = tree[1]:root()
	local node = root:named_descendant_for_range(row, 0, row, 0)

	while node do
		local ntype = node:type()
		if ntype:match("function") or ntype:match("method") or ntype == "func_literal" then
			if not result.function_name then
				result.function_name = M._get_node_name(node)
			end
		end
		if ntype:match("class") or ntype:match("struct") or ntype == "type_declaration" or ntype == "interface_declaration" then
			if not result.class_name then
				result.class_name = M._get_node_name(node)
			end
		end
		if ntype == "module" or ntype == "package_clause" or ntype == "namespace" then
			if not result.module_name then
				result.module_name = M._get_node_name(node)
			end
		end
		node = node:parent()
	end

	return result
end

function M._get_node_name(node)
	for child in node:iter_children() do
		local ctype = child:type()
		if ctype == "identifier" or ctype == "name" or ctype == "type_identifier" or ctype == "field_identifier" then
			return vim.treesitter.get_node_text(child, 0)
		end
	end
	return nil
end

function M.auto_tags()
	local ctx = M.get_context()
	local tags = {}
	if ctx.filetype and ctx.filetype ~= "" then
		table.insert(tags, "lang:" .. ctx.filetype)
	end
	if ctx.function_name then
		table.insert(tags, "fn:" .. ctx.function_name)
	end
	if ctx.class_name then
		table.insert(tags, "class:" .. ctx.class_name)
	end
	if ctx.module_name then
		table.insert(tags, "module:" .. ctx.module_name)
	end
	return tags
end

return M
