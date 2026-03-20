local M = {}

-- Tier 1
M.memory = require("mdemg.api.memory")
M.health = require("mdemg.api.health")
M.jiminy = require("mdemg.api.jiminy")
M.conversation = require("mdemg.api.conversation")
M.symbols = require("mdemg.api.symbols")

-- Tier 2
M.ingest = require("mdemg.api.ingest")
M.jobs = require("mdemg.api.jobs")
M.constraints = require("mdemg.api.constraints")
M.learning = require("mdemg.api.learning")
M.rsic = require("mdemg.api.rsic")
M.backup = require("mdemg.api.backup")
M.scraper = require("mdemg.api.scraper")
M.neural = require("mdemg.api.neural")
M.gaps = require("mdemg.api.gaps")
M.skills = require("mdemg.api.skills")
M.hash = require("mdemg.api.hash")
M.spaces = require("mdemg.api.spaces")

-- Tier 3
M.admin = require("mdemg.api.admin")
M.linear = require("mdemg.api.linear")
M.plugins = require("mdemg.api.plugins")
M.watcher = require("mdemg.api.watcher")
M.webhooks = require("mdemg.api.webhooks")
M.snapshots = require("mdemg.api.snapshots")
M.templates = require("mdemg.api.templates")
M.org_reviews = require("mdemg.api.org_reviews")

return M
