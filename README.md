# mdemg.nvim

Neovim plugin for [MDEMG](https://github.com/reh3376/mdemg) — keyboard-driven access to your AI memory graph.

24 commands across 3 tiers provide full coverage of MDEMG's REST API surface directly from Neovim.

## Requirements

- Neovim >= 0.10
- `curl` on PATH
- Running MDEMG instance (`mdemg start`)

## Installation

For the full installation guide — including detailed configuration options, multi-project setup, statusline integration, troubleshooting, and startup behavior — see the [Installation Guide](https://github.com/reh3376/mdemg/blob/main/docs/guides/nvim/mdemg-plugin/installation.md).

**lazy.nvim:**
```lua
{
  "reh3376/mdemg.nvim",
  config = function()
    require("mdemg").setup()
  end,
}
```

**packer.nvim:**
```lua
use {
  "reh3376/mdemg.nvim",
  config = function()
    require("mdemg").setup()
  end,
}
```

## Quick Start

```lua
require("mdemg").setup({
  endpoint = "http://localhost:9999", -- default
  -- space_id auto-resolves from project directory name
})
```

## Commands

### Tier 1 — Core

| Command | Description |
|---------|-------------|
| `:MdemgRecall [query]` | Search the memory graph (visual mode: use selection) |
| `:MdemgStore` | Store observation (visual mode: store selection) |
| `:MdemgValidate` | Validate buffer changes against guardrail constraints |
| `:MdemgGuide` | Get Jiminy guidance for current cursor context |
| `:MdemgReflect [topic]` | Deep reflection across the memory graph |
| `:MdemgSymbols [query]` | Search code symbols with jump-to-definition |
| `:MdemgStatus` | Show instance status in a floating window |

### Tier 2 — Operational

| Command | Subcommands |
|---------|-------------|
| `:MdemgIngest` | `trigger`, `status`, `cancel`, `jobs`, `files` |
| `:MdemgConversation` | `observe`, `correct`, `recall`, `resume`, `consolidate`, `graduate`, `volatile-stats`, `session-health` |
| `:MdemgConstraints` | `list`, `stats`, `effectiveness`, `conflicts`, `detect-conflicts` |
| `:MdemgLearning` | `stats`, `freeze`, `unfreeze`, `freeze-status`, `prune`, `distribution`, `frontiers` |
| `:MdemgRSIC` | `cycle`, `assess`, `report`, `history`, `calibration`, `health`, `signals`, `rollback`, `reset` |
| `:MdemgBackup` | `trigger`, `list`, `status`, `manifest`, `restore`, `delete` |
| `:MdemgScraper` | `scrape`, `list`, `status`, `cancel`, `review` |
| `:MdemgNeural` | `status` |
| `:MdemgGaps` | `list`, `detail`, `interviews`, `interview-detail`, `feedback` |
| `:MdemgSkills` | `list`, `recall`, `register` |
| `:MdemgHash` | `register`, `files`, `verify`, `verify-all`, `update`, `revert`, `scan`, `lookup` |

### Tier 3 — Admin

| Command | Subcommands |
|---------|-------------|
| `:MdemgAdmin` | `spaces`, `space-detail`, `prune`, `export-preview`, `export`, `import`, `meta-learn` |
| `:MdemgLinear` | `issues`, `issue-detail`, `projects`, `project-detail`, `comments`, `create-comment` |
| `:MdemgPlugins` | `list`, `modules`, `ape-status`, `ape-trigger`, `detail`, `module-detail` |
| `:MdemgWatcher` | `start`, `status`, `stop` |
| `:MdemgWebhooks` | `trigger` |
| `:MdemgHealth` | Aggregated dashboard (readyz, stats, RSIC, learning, neural) |

All Tier 2/3 commands accept subcommands as arguments. Running without a subcommand opens a picker.

## Default Keymaps

| Key | Action |
|-----|--------|
| `<leader>mr` | Recall memories |
| `<leader>ms` | Store observation |
| `<leader>mv` | Validate changes |
| `<leader>mg` | Get guidance |
| `<leader>mf` | Reflect on topic |
| `<leader>my` | Search symbols |
| `<leader>mi` | Show status |

Disable any keymap by setting it to `""` in setup.

## Statusline

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      {
        require("mdemg.ui.statusline").component,
        color = require("mdemg.ui.statusline").color,
      },
    },
  },
})
```

## Optional Dependencies

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) — enhanced result picking with preview
- [nvim-notify](https://github.com/rcarriga/nvim-notify) — better notifications
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) — statusline integration
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) — context-aware auto-tagging

## Features

- Per-buffer instance resolution (multi-project support via `.mdemg.port` walk-up)
- Session lifecycle (auto-create on VimEnter, auto-consolidate on VimLeavePre)
- Auto-ingest on file save with debouncing
- Health polling for statusline updates
- SSE streaming for job progress display
- Connection health tracking (3 consecutive failures = unhealthy)
- Telescope integration with `vim.ui.select` fallback

## Health Check

```vim
:checkhealth mdemg
```

## License

MIT
