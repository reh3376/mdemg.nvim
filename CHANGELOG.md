# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-20

### Added

- 24 commands across 3 tiers covering the full MDEMG REST API surface
- **Tier 1 (Core):** MdemgRecall, MdemgStore, MdemgValidate, MdemgGuide, MdemgReflect, MdemgSymbols, MdemgStatus
- **Tier 2 (Operational):** MdemgIngest, MdemgConversation, MdemgConstraints, MdemgLearning, MdemgRSIC, MdemgBackup, MdemgScraper, MdemgNeural, MdemgGaps, MdemgSkills, MdemgHash
- **Tier 3 (Admin):** MdemgAdmin, MdemgLinear, MdemgPlugins, MdemgWatcher, MdemgWebhooks, MdemgHealth
- Per-buffer instance resolution with `.mdemg.port` walk-up for multi-project support
- Session lifecycle management (auto-create on VimEnter, auto-consolidate on VimLeavePre)
- Auto-ingest on file save with debouncing
- Health polling for statusline updates
- SSE streaming for job progress display
- Connection health tracking (3 consecutive failures = unhealthy)
- Telescope integration with `vim.ui.select` fallback
- Lualine statusline component with configurable format (short/long) and icons
- Floating window UI for status display, recall results, and guidance
- Visual mode support for recall and store commands
- Default keymaps (`<leader>m` prefix) with per-key disable support
- `:checkhealth mdemg` integration
- Plugin install and validate subcommands for `:MdemgPlugins`
- 99 plenary tests, luacheck + stylua CI

[0.1.0]: https://github.com/reh3376/mdemg.nvim/releases/tag/v0.1.0
