local M = {}

M.check = function()
	vim.health.start("mdemg.nvim")

	if vim.fn.has("nvim-0.10") == 1 then
		vim.health.ok("Neovim >= 0.10")
	else
		vim.health.error("Neovim >= 0.10 required")
	end

	if vim.fn.executable("curl") == 1 then
		vim.health.ok("curl found")
	else
		vim.health.error("curl not found — required for API communication")
	end

	local cwd = vim.fn.getcwd()
	if vim.fn.isdirectory(cwd .. "/.mdemg") == 1 then
		vim.health.ok(".mdemg/ directory found in " .. cwd)
	else
		vim.health.warn("No .mdemg/ directory in " .. cwd .. " — run `mdemg init`")
	end

	if vim.fn.filereadable(cwd .. "/.mdemg.port") == 1 then
		vim.health.ok(".mdemg.port file present")
	else
		vim.health.info("No .mdemg.port — instance may not be running")
	end

	local endpoint = vim.b.mdemg_endpoint or vim.g.mdemg_endpoint or require("mdemg.config").get().endpoint
	local result =
		vim.fn.system({ "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", "--max-time", "3", endpoint .. "/readyz" })
	if result == "200" then
		vim.health.ok("MDEMG instance reachable at " .. endpoint)
	else
		vim.health.warn("MDEMG instance not reachable at " .. endpoint .. " — run `mdemg start`")
	end

	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	if space_id then
		vim.health.ok("Space ID: " .. space_id)
	else
		vim.health.info("No space ID resolved")
	end

	local optionals = {
		{ "telescope", "telescope.nvim" },
		{ "notify", "nvim-notify" },
		{ "lualine", "lualine.nvim" },
	}
	for _, dep in ipairs(optionals) do
		local ok = pcall(require, dep[1])
		if ok then
			vim.health.ok(dep[2] .. " available")
		else
			vim.health.info(dep[2] .. " not installed (optional)")
		end
	end

	local ts_ok = pcall(require, "nvim-treesitter")
	if ts_ok then
		vim.health.ok("nvim-treesitter available")
	else
		vim.health.info("nvim-treesitter not installed (optional, used for auto-tagging)")
	end
end

return M
