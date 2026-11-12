# Verification

Run on 2026-11-12 on macOS (Apple Silicon) with Mixar 4.4.3 (`/Applications/Mixar.app`) signed in, and Claude Code 2.1.322.

## Packaging

| Check | Result |
|---|---|
| `claude plugin validate .` | Passed |
| `claude plugin validate . --profile directory` | Passed, nothing to report |
| Listing icon | `assets/icon.png`, the shipped Mixar app icon, 1024 × 1024 PNG with transparency |
| Layout | No top-level `bin/`; the server command is `${CLAUDE_PLUGIN_ROOT}/scripts/mixar-mcp` with no other variable, no shell wrapper and no package launcher |

## Claude Code

| Check | Result |
|---|---|
| `claude --plugin-dir <repo> mcp list` (run outside the repo) | `plugin:mixar:mixar: <repo>/scripts/mixar-mcp - ✔ Connected` |

## The server command, spoken to over MCP stdio

The command from `.mcp.json`, with `${CLAUDE_PLUGIN_ROOT}` expanded and no `MIXAR_*` variables set, driven by a small MCP client (initialize, tools/list, tools/call):

| Check | Result |
|---|---|
| Initialize | Server `Mixar`, protocol `2025-06-18` |
| Tool list with Mixar closed (saved list) | 76 tools in 1.3 s |
| `mixar_status` with Mixar closed | `Mixar is starting or unavailable`, and the call started the installed Mixar app |
| Tool list with Mixar running | 73 tools in 4.3 s; no duplicate names; longest name 27 characters |
| `mixar_status` with Mixar running | `connected: true` with instance and session ids |
| Annotations | `readOnlyHint` and `destructiveHint` on all 73 tools; `title` on none (see below) |

## Launcher script

| Check | Result |
|---|---|
| Launcher missing | Exit 1, empty stdout, stderr names the path and points to Connect MCP and `/mcp` |
| `HOME` unset | Exit 1, empty stdout, "HOME is not set" |
| `MIXAR_MCP_LAUNCHER` override with arguments containing spaces | Arguments passed through unchanged |
| Default path in a home folder containing a space | Resolved |
| Process | `exec` replaces the script |
| `sh -n` | Passed |
| Installation record without `"hide_media_generation"` in `features`, or no record (Mixar 4.4.3 and older) | Exit 1, empty stdout, "this Mixar version cannot run with Claude yet", update and reconnect |
| Installation record listing `"hide_media_generation"` | Launcher started with the arguments unchanged |

## Open findings

Both findings from the first run are being closed in Mixar itself (Mixar-AI/mixar-backend#2024, Mixar-AI/mixar-texture-painting#2078, tracked in Mixar-AI/mixar-backend#2023):

- Tool `title`s (policy 5.E): every Mixar tool gets a `title` and `annotations.title`, for every MCP client.
- AI image and video generation (policy 4.B): with `MIXAR_MCP_HIDE_MEDIA_GENERATION=1`, which `.mcp.json` sets, Mixar leaves `image_gen`, `depth_to_image`, `video_gen`, `video_upscale` and `brush_gen` out of its tools, descriptions and guide, refuses them (including from scripts), and does not offer `mixar_ui_act`. The script above refuses to start with a Mixar that predates this, so the plugin never runs with media generation available.

Until the Mixar release that carries those changes ships, the plugin does not start against an installed Mixar. The results above the launcher-script table were taken with Mixar 4.4.3, before that check existed.

## Not executed

- A model-driven Claude Code session using the skill and the tools.
- A Cowork session on this computer.
- Linux and Windows. Windows is not supported: `.mcp.json` names the POSIX script.
- Signed out, MCP turned off, and several Mixar apps open at once through this plugin. The launcher's handling of these states is shared with the Hermes and OpenAI packages, where it was tested.
- The developer portal's **Validate** and security scan.
