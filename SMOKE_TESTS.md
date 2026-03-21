# mdemg.nvim Smoke Tests & Edge Cases

Pre-release manual testing checklist. These tests require a running MDEMG server and Neovim with mdemg.nvim loaded.

## Prerequisites

1. MDEMG server running: `curl -s http://localhost:9999/readyz` returns 200
2. Neo4j running with data in `mdemg-dev` space
3. Working directory: `cd /Users/reh3376/mdemg`
4. Open a Go file: `nvim internal/api/server.go`

---

## Tier 1 Smoke Tests (Core)

| ID | Command / Steps | Expected Behavior | Pass |
|---|---|---|---|
| **ST-1.1** | `:MdemgRecall retrieval pipeline` | Telescope picker with scored results. Select one → detail float. `q` closes. | [ ] |
| **ST-1.2** | `:MdemgRecall` (no args) | Input prompt appears. Type query, Enter → results | [ ] |
| **ST-1.3** | Visual select word → `<leader>Mr` | Selection used as query, no prompt | [ ] |
| **ST-1.4** | `:MdemgStore` | Editable float opens. Type text, `Ctrl-s` submits | [ ] |
| **ST-1.5** | Visual select lines → `<leader>Ms` | No editor float. Selection stored directly | [ ] |
| **ST-1.6** | Edit a git-tracked file → `:MdemgValidate` | Float shows "Validation: Pass/Warning/Block" | [ ] |
| **ST-1.7** | `:MdemgValidate` with no changes | "No changes to validate" notification | [ ] |
| **ST-1.8** | `:MdemgGuide` (cursor in function) | NE-anchored float with Jiminy guidance. `+`/`-` feedback. Auto-closes ~10s | [ ] |
| **ST-1.9** | `:MdemgReflect Hebbian learning` | Vsplit with markdown: Core Memories, Concepts, Insights | [ ] |
| **ST-1.10** | `:MdemgSymbols VectorRecall` | Picker with symbols. Select → jumps to file:line | [ ] |
| **ST-1.11** | `:MdemgStatus` | Float shows version, endpoint, stats. Async loads then updates | [ ] |
| **ST-1.12** | `:checkhealth mdemg` | Version 0.1.0, Neovim OK, curl OK, endpoint OK | [ ] |
| **ST-1.13** | Test each `<leader>M*` keymap | Each triggers correct command (7 keymaps) | [ ] |

## Tier 2 Smoke Tests (Extended)

| ID | Command | Pass Criteria | Pass |
|---|---|---|---|
| **ST-2.1** | `:MdemgIngest` (picker) | 5 subcommands shown, selection works | [ ] |
| **ST-2.2** | `:MdemgIngest trigger` | Job created, progress float appears | [ ] |
| **ST-2.3** | `:MdemgConversation observe` | Two-step prompt, observation stored | [ ] |
| **ST-2.4** | `:MdemgLearning stats` | Float with learning data | [ ] |
| **ST-2.5** | `:MdemgRSIC health` | Float with RSIC data | [ ] |
| **ST-2.6** | `:MdemgBackup list` | Float shows backups or empty msg | [ ] |
| **ST-2.7** | `:MdemgConstraints list` | Float shows constraints or empty msg | [ ] |
| **ST-2.8** | `:MdemgSkills list` | Float shows skills | [ ] |

## Tier 3 Smoke Tests (Admin)

| ID | Command | Pass Criteria | Pass |
|---|---|---|---|
| **ST-3.1** | `:MdemgAdmin spaces` | Space list appears (includes mdemg-dev) | [ ] |
| **ST-3.2** | `:MdemgHealth` | Dashboard loads 5 sections | [ ] |
| **ST-3.3** | `:MdemgLinear issues` | Display appears (or meaningful error if not configured) | [ ] |

## Auto Behavior Smoke Tests

| ID | Steps | Pass Criteria | Pass |
|---|---|---|---|
| **ST-A.1** | Restart Neovim → `:lua print(vim.g.mdemg_session_id)` | Format: `nvim-<ts>-<hash>` | [ ] |
| **ST-A.2** | Edit .go file, save, wait 3s | No error notification, server shows ingest | [ ] |
| **ST-A.3** | Edit .txt file, save | No ingest triggered (not in extension list) | [ ] |
| **ST-A.4** | Wait 30s → `:lua print(require("mdemg.ui.statusline")._state.connected)` | `true` | [ ] |
| **ST-A.5** | `:lua print(vim.b.mdemg_endpoint, vim.b.mdemg_space_id)` | Both non-nil | [ ] |
| **ST-A.6** | Set `vim.g.mdemg_space_id = "override"` then `:lua print(require("mdemg.client").resolve_space_id())` | Returns "override" regardless of vim.b | [ ] |
| **ST-A.7** | `:MdemgRefresh` | Shows "Refreshed -- endpoint=... space_id=..." notification | [ ] |
| **ST-A.8** | Edit `.mdemg/config.yaml` to change space_id, switch buffers | New space_id auto-detected without restart | [ ] |

---

## Edge Cases & Error Handling

### Server Down (stop MDEMG server first)

| ID | Scenario | Expected | Pass |
|---|---|---|---|
| **EC-1** | Run all Tier 1 commands with server stopped | Error notification per command, no crash | [ ] |
| **EC-2** | Statusline after 60s with server down | `connected = false` | [ ] |
| **EC-3** | Restart server, wait 60s | Auto-recovers to `connected = true` | [ ] |

### Missing Config

| ID | Scenario | Expected | Pass |
|---|---|---|---|
| **EC-4** | Open file outside any `.mdemg/` directory | Falls back to default endpoint, no crash | [ ] |
| **EC-5** | No space_id in config or env | Warning notification, space_id nil | [ ] |

### Empty / Unexpected Responses

| ID | Scenario | Expected | Pass |
|---|---|---|---|
| **EC-6** | `:MdemgRecall zzzzxxx_nonexistent_gibberish` | "No results found" notification | [ ] |
| **EC-7** | `:MdemgValidate` outside git repo | Graceful fallback to buffer_vs_disk | [ ] |
| **EC-8** | `:MdemgSymbols zzzzNonExistent` | "No symbols found" notification | [ ] |

### Optional Dependency Degradation

| ID | Scenario | Expected | Pass |
|---|---|---|---|
| **EC-9** | Remove telescope from rtp → `:MdemgRecall` | Falls back to vim.ui.select | [ ] |
| **EC-10** | Remove nvim-notify → any command | Falls back to vim.notify | [ ] |
| **EC-11** | No treesitter parser → `:MdemgStore` visual | Store succeeds, tags lack fn/class | [ ] |

### Timeout & Concurrency

| ID | Scenario | Expected | Pass |
|---|---|---|---|
| **EC-12** | `setup({ timeout = 1 })` + slow endpoint | "Request timed out" message | [ ] |
| **EC-13** | `:MdemgRecall test` 5x rapidly | All complete, no crash | [ ] |
| **EC-14** | Open Status float → run Guide | Both floats coexist, no crash | [ ] |

---

## Test Counts

| Category | Count | Automated? | CI? |
|---|---|---|---|
| Unit tests | 307 | Yes | Yes (auto-discovered) |
| Integration tests | 6 suites | Yes (gated by `MDEMG_INTEGRATION=1`) | Optional |
| Smoke tests (above) | 32 procedures | Manual | No |
| Edge cases (above) | 14 procedures | Manual | No |
