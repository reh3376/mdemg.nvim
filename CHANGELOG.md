# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- **Space ID resolution fragility** — removed silent basename fallback that returned wrong values (e.g., "mdemg" instead of "mdemg-dev"). Now returns nil with a warning when no source provides space_id, guiding users to configure it explicitly.
- **vim.g override precedence** — `vim.g.mdemg_space_id` (user override) now correctly wins over `vim.b.mdemg_space_id` (auto-detected). Previously vim.b took priority, making vim.g unreachable.
- **BufEnter cache poisoning** — float, terminal, and scratch buffers no longer trigger instance/space resolution (buftype filter). Nil space_id results no longer set vim.b, preserving fallback chain.

### Added

- `:MdemgRefresh` command — clears instance/space caches and re-resolves, useful after config changes
- `DirChanged` autocmd — automatically clears caches when working directory changes
- Mtime-based cache invalidation for space.lua — config.yaml edits take effect on next BufEnter without restarting Neovim
- `client.resolve_endpoint()` and `client.resolve_space_id()` public API — centralized resolution replacing 37 inline patterns across 20 files
- 307 unit tests (up from 99), 6 integration test suites, SMOKE_TESTS.md with 32 manual procedures and 14 edge cases

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
- Plenary tests, luacheck + stylua CI

[0.1.0]: https://github.com/reh3376/mdemg.nvim/releases/tag/v0.1.0
