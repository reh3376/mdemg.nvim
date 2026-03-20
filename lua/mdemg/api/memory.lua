local M = {}
local client = require("mdemg.client")

function M.retrieve(query, opts, callback)
	opts = opts or {}
	local body = {
		query_text = query,
		candidate_k = opts.candidate_k,
		top_k = opts.top_k or 10,
		hop_depth = opts.hop_depth,
		include_evidence = opts.include_evidence or false,
		code_only = opts.code_only,
		include_extensions = opts.include_extensions,
		temporal_after = opts.temporal_after,
		temporal_before = opts.temporal_before,
		translate_intent = opts.translate_intent,
		cursor = opts.cursor,
		limit = opts.limit,
	}
	client.post("/v1/memory/retrieve", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.ingest(content, metadata, callback)
	metadata = metadata or {}
	local body = {
		content = content,
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		source = metadata.source or "neovim-observation",
		tags = metadata.tags,
		path = metadata.path,
		name = metadata.name,
		summary = metadata.summary,
		sensitivity = metadata.sensitivity or "internal",
		confidence = metadata.confidence,
		canonical_time = metadata.canonical_time,
	}
	client.post("/v1/memory/ingest", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.ingest_files(paths, callback)
	local body = {
		files = paths,
		extract_symbols = true,
	}
	client.post("/v1/memory/ingest/files", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.reflect(topic, opts, callback)
	opts = opts or {}
	local body = {
		topic = topic,
		max_depth = opts.max_depth or 3,
		max_nodes = opts.max_nodes or 50,
	}
	client.post("/v1/memory/reflect", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.stats(callback)
	local space_id = vim.b.mdemg_space_id or vim.g.mdemg_space_id
	client.get("/v1/memory/stats", {
		params = space_id and { space_id = space_id } or nil,
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

function M.validate(diff, files, callback)
	local body = {
		diff = diff,
		files_changed = files,
	}
	client.post("/v1/memory/guardrail/validate", body, {
		on_success = function(_, data)
			callback(nil, data)
		end,
		on_error = function(err)
			callback(err)
		end,
	})
end

return M
