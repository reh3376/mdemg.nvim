if vim.g.loaded_mdemg then
	return
end
vim.g.loaded_mdemg = true

if vim.fn.has("nvim-0.10") == 0 then
	vim.notify("mdemg.nvim requires Neovim 0.10+", vim.log.levels.ERROR)
	return
end

local function register_commands()
	vim.api.nvim_create_user_command("MdemgRecall", function(cmd_opts)
		local query = cmd_opts.args ~= "" and cmd_opts.args or nil
		require("mdemg.actions.recall").run({ query = query })
	end, {
		nargs = "?",
		range = true,
		desc = "Recall memories from MDEMG",
	})

	vim.api.nvim_create_user_command("MdemgStore", function()
		require("mdemg.actions.store").run()
	end, {
		range = true,
		desc = "Store observation in MDEMG",
	})

	vim.api.nvim_create_user_command("MdemgValidate", function()
		require("mdemg.actions.validate").run()
	end, {
		desc = "Validate changes against MDEMG guardrails",
	})

	vim.api.nvim_create_user_command("MdemgGuide", function()
		require("mdemg.actions.guide").run()
	end, {
		desc = "Get Jiminy guidance for current context",
	})

	vim.api.nvim_create_user_command("MdemgReflect", function(cmd_opts)
		local topic = cmd_opts.args ~= "" and cmd_opts.args or nil
		require("mdemg.actions.reflect").run({ topic = topic })
	end, {
		nargs = "?",
		range = true,
		desc = "Deep reflection on a topic",
	})

	vim.api.nvim_create_user_command("MdemgSymbols", function(cmd_opts)
		local query = cmd_opts.args ~= "" and cmd_opts.args or nil
		require("mdemg.actions.recall").run({ symbols = true, query = query })
	end, {
		nargs = "?",
		desc = "Search symbols in MDEMG",
	})

	vim.api.nvim_create_user_command("MdemgStatus", function()
		require("mdemg.ui.statusline").show_status()
	end, {
		desc = "Show MDEMG instance status",
	})

	-- Tier 2: Operational Workflows
	local tier2 = {
		{ "MdemgIngest", "mdemg.actions.ingest", "Ingestion management" },
		{ "MdemgConversation", "mdemg.actions.conversation", "Conversation memory" },
		{ "MdemgConstraints", "mdemg.actions.constraints", "Constraint management" },
		{ "MdemgLearning", "mdemg.actions.learning", "Learning system controls" },
		{ "MdemgRSIC", "mdemg.actions.rsic", "RSIC self-improvement" },
		{ "MdemgBackup", "mdemg.actions.backup", "Backup and restore" },
		{ "MdemgScraper", "mdemg.actions.scraper", "Web scraper jobs" },
		{ "MdemgNeural", "mdemg.actions.neural", "Neural sidecar" },
		{ "MdemgGaps", "mdemg.actions.gaps", "Capability gap analysis" },
		{ "MdemgSkills", "mdemg.actions.skills", "Skill registry" },
		{ "MdemgHash", "mdemg.actions.hash", "Hash verification" },
	}
	for _, cmd in ipairs(tier2) do
		vim.api.nvim_create_user_command(cmd[1], function(cmd_opts)
			require(cmd[2]).run(cmd_opts.fargs)
		end, { nargs = "*", desc = cmd[3] })
	end

	-- Tier 3: Admin & Polish
	local tier3 = {
		{ "MdemgAdmin", "mdemg.actions.admin", "Admin space management" },
		{ "MdemgLinear", "mdemg.actions.linear", "Linear integration" },
		{ "MdemgPlugins", "mdemg.actions.plugins", "Plugin and module management" },
		{ "MdemgWatcher", "mdemg.actions.watcher", "File watcher control" },
		{ "MdemgWebhooks", "mdemg.actions.webhooks", "Webhook management" },
	}
	for _, cmd in ipairs(tier3) do
		vim.api.nvim_create_user_command(cmd[1], function(cmd_opts)
			require(cmd[2]).run(cmd_opts.fargs)
		end, { nargs = "*", desc = cmd[3] })
	end

	vim.api.nvim_create_user_command("MdemgHealth", function()
		require("mdemg.actions.health_dashboard").run()
	end, { desc = "Aggregated health dashboard" })
end

register_commands()

vim.api.nvim_create_user_command("MdemgRefresh", function()
	require("mdemg.util.instance").clear_cache()
	require("mdemg.util.space").clear_cache()
	local bufpath = vim.api.nvim_buf_get_name(0)
	if bufpath ~= "" and vim.bo.buftype == "" then
		local info = require("mdemg.util.instance").resolve(bufpath)
		if info then
			vim.b.mdemg_endpoint = info.endpoint
			local sid = require("mdemg.util.space").resolve(info.project_root)
			if sid then
				vim.b.mdemg_space_id = sid
			end
		end
	end
	local client = require("mdemg.client")
	vim.notify(
		string.format(
			"[mdemg] Refreshed — endpoint=%s space_id=%s",
			client.resolve_endpoint() or "nil",
			client.resolve_space_id() or "nil"
		),
		vim.log.levels.INFO
	)
end, { desc = "Clear MDEMG caches and re-resolve instance/space" })
