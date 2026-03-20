local M = {}

function M.buffer_diff()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		return nil
	end

	local result = vim.fn.system({ "git", "diff", "HEAD", "--", filepath })
	if vim.v.shell_error ~= 0 then
		result = vim.fn.system({ "git", "diff", "--", filepath })
		if vim.v.shell_error ~= 0 then
			return nil
		end
	end

	if result and vim.trim(result) ~= "" then
		return result
	end

	return M.buffer_vs_disk()
end

function M.buffer_vs_disk()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" or vim.fn.filereadable(filepath) == 0 then
		return nil
	end

	local disk_lines = vim.fn.readfile(filepath)
	local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	local diff = vim.diff(table.concat(disk_lines, "\n"), table.concat(buf_lines, "\n"), {
		result_type = "unified",
		ctxlen = 3,
	})

	if diff and vim.trim(diff) ~= "" then
		return diff
	end
	return nil
end

function M.changed_files()
	local result = vim.fn.system({ "git", "diff", "--name-only", "HEAD" })
	if vim.v.shell_error ~= 0 then
		return {}
	end
	local files = vim.split(vim.trim(result), "\n")
	return vim.tbl_filter(function(f)
		return f ~= ""
	end, files)
end

return M
