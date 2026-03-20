local M = {}

M.defaults = {
	endpoint = "http://localhost:9999",
	space_id = nil,
	timeout = 30,
	keymaps = {
		recall = "<leader>mr",
		store = "<leader>ms",
		validate = "<leader>mv",
		guide = "<leader>mg",
		reflect = "<leader>mf",
		symbols = "<leader>my",
		status = "<leader>mi",
	},
	session = {
		auto_create = true,
		auto_consolidate = true,
	},
	auto = {
		ingest_on_save = true,
		ingest_debounce_ms = 2000,
		ingest_extensions = { "go", "py", "lua", "js", "ts", "tsx", "jsx", "rs", "java", "rb", "c", "cpp", "h", "hpp" },
		health_poll_interval = 30,
		stats_refresh_interval = 120,
	},
	ui = {
		border = "rounded",
		width = 0.8,
		height = 0.8,
		use_telescope = true,
		use_notify = true,
		float_timeout = 10,
	},
	statusline = {
		format = "short",
		icons = true,
	},
	guardrail = {
		auto_validate = false,
	},
	log_level = "warn",
}

M._config = nil

local valid_log_levels = { debug = true, info = true, warn = true, error = true }

function M.setup(user_opts)
	user_opts = user_opts or {}
	M._config = vim.tbl_deep_extend("force", {}, M.defaults, user_opts)
	M.validate(M._config)
end

function M.get()
	return M._config or M.defaults
end

function M.validate(cfg)
	if type(cfg.endpoint) ~= "string" then
		vim.notify("[mdemg] endpoint must be a string", vim.log.levels.WARN)
	end
	if type(cfg.timeout) ~= "number" then
		vim.notify("[mdemg] timeout must be a number", vim.log.levels.WARN)
	end
	if not valid_log_levels[cfg.log_level] then
		vim.notify("[mdemg] log_level must be one of: debug, info, warn, error", vim.log.levels.WARN)
	end
end

return M
