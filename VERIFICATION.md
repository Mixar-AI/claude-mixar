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

## Open findings

- No Mixar tool has a `title`. The Anthropic Software Directory Policy (5.E) asks for `title`, `readOnlyHint` and `destructiveHint` on every tool. The tool list comes from the Mixar app, so this needs a Mixar change.
- `enqueue_generation` offers image and video job types (`image_gen`, `depth_to_image`, `video_gen`, `video_upscale`). The policy (4.B) does not accept software that generates images, video or audio with AI models, except design assets. This also needs a Mixar change or a written exception from Anthropic.

## Not executed

- A model-driven Claude Code session using the skill and the tools.
- A Cowork session on this computer.
- Linux and Windows. Windows is not supported: `.mcp.json` names the POSIX script.
- Signed out, MCP turned off, and several Mixar apps open at once through this plugin. The launcher's handling of these states is shared with the Hermes and OpenAI packages, where it was tested.
- The developer portal's **Validate** and security scan.
