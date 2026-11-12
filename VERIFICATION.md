# Verification

## Repository validation correction (2026-11-12)

The first developer-portal attempt stopped with “Couldn’t validate that repository”.
The repository contained `text`/`eol` rules in `.gitattributes`; Anthropic's
[pre-submission checklist](https://claude.com/docs/plugins/pre-submission-checklist)
rejects attributes that rewrite file contents. Those rules have been removed.
The Windows launcher is now stored with CRLF directly in Git, matching the
SHA-256 of the launcher in the successful Windows run recorded below; the POSIX
launcher remains LF. When editing launchers, preserve these existing line endings
and stage with `git -c core.autocrlf=false add --renormalize scripts/mixar-mcp scripts/mixar-mcp.cmd`.

The tracked tree was also checked for invalid UTF-8, unsupported path characters,
trailing dots/spaces, Windows device names, case collisions, symlinks, submodules,
and LFS pointers; none were found. Local and remote refs contain no replace refs.
Portal re-validation is still required against the corrected commit.

## Current plugin: macOS and Windows

Verified on 2026-11-12 with Claude Code 2.1.322 and the development Mixar build containing the media-generation restriction. The macOS run passed in the original session; the Windows run completed after resuming it.

Windows run: `20261112-120801-rajmixar.app-task-2023-hide-media-gen`, client `fd99da9c473217b60b7597272b0acb2329ebe600`, backend `https://uat8.mixar.app`, harness base `ac40d49f5c2ba0f47377ce7664ac0b198b3f65dd` plus the new `scenarios/claude_plugin_e2e.py`. The plugin used base `155cd2d` plus the Windows launcher and its line-ending declaration.

| Check | macOS | Windows |
|---|---|---|
| `claude plugin validate` | Passed | Passed; non-blocking advice to add a marketplace install command once available |
| `claude --plugin-dir <plugin> mcp list` | Connected | Connected; extensionless command resolves to the `.cmd` launcher |
| Plugin command over MCP stdio | 75 tools | 75 tools |
| Media-free tool list, descriptions and instructions; 3D job types retained; every tool titled | Passed | Passed |
| `mixar_ui_act` absent | Passed | Passed |
| Older Mixar installation record | Exit 1 with update guidance; Claude reports failed connection | Same |
| Missing Mixar launcher | Exit 1 with path and setup guidance | Same |
| MCP remains ready; preferences restored afterwards | Passed | Passed |
| Separate startup smoke test | Not part of this plugin run | Passed (34 s) |

The Windows plugin scenario took 38 s. It used a private Claude config directory and an isolated QA app; no Claude sign-in, model turn or generation was needed. The QA lane was released afterwards. The optional process watcher was unavailable on Windows because `psutil` was not installed; launcher discovery and installation records were still isolated, with auto-start disabled. The MCP process exited cleanly.

The Connect MCP screenshots were visually checked before and after the run: both show “MCP is on · AI apps can connect to this Mixar”, with the dialog and controls visible. Retained evidence: [Windows results](docs/qa/2026-11-12/windows-plugin.json), [before](docs/qa/2026-11-12/windows-connect-before.png), [after](docs/qa/2026-11-12/windows-connect-after.png).

This verifies the local plugin connection and tool surface. Cowork, Linux plugin loading and the submission portal checks remain untested. Release support still depends on shipping the client/backend changes below.

## Real Claude workflow

Passed on macOS on 2026-11-12, run `scenarios-20261112-190745`, Claude Code
2.1.322 (`claude-opus-5-5`), plugin `f7c0d2b`, client `fd99da9c4`, uat8.
The test loads the plugin skill and its exact MCP server command in a private
plugin copy, with discovery pinned to the isolated QA app. Because Claude's
strict MCP mode excludes plugin-discovered servers too, the test passes that
same server definition explicitly under `plugin:mixar:mixar`. This exercises
the plugin's launcher and skill; the separate connection test above covers
automatic plugin-server discovery.

Claude inspected the original scene, created a new tab, built a one-metre
crate with scripts and simple brown materials, rendered two hero previews,
fixed a brace-contact issue, and exported only the crate as GLB for Godot.
The export tool reported successful read-back verification with no issues or
warnings. Independent QA scene inspection found the four crate meshes, and
an independent GLB header/JSON read confirmed four meshes, four materials,
31,612 bytes and no cameras. No tool permissions were denied. Mixar credits
stayed at 83,165; Claude inference used the existing signed-in subscription.
The QA preferences were restored and the owned app was stopped.

Both hero renders and the final app screenshot were visually checked. The
slats and diagonal braces are visible, and the new scene is separate from
the original. [Preview](docs/qa/2026-11-12/claude-crate-preview.jpg) ·
[Results](docs/qa/2026-11-12/claude-workflow.json).

Two earlier attempts are retained locally: the first excluded the plugin
server through an empty strict MCP config; the second completed the export
but the harness denied the read-only `list_rules` call. The corrected
scenario explicitly supplies the server and permits that read-only tool.
Neither is counted as a passing test. The GLB was not opened in Godot.

## Initial baseline (before the capability check)

The following baseline was run on 2026-11-12 on macOS (Apple Silicon) with installed Mixar 4.4.3 (`/Applications/Mixar.app`) signed in, and Claude Code 2.1.322. It does not describe the current plugin against that release: the capability check now rejects it.

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

Both findings from the first run are implemented, verified and merged into `feature/mixar-blastoff` (Mixar-AI/mixar-backend#2024, Mixar-AI/mixar-texture-painting#2078, tracked in Mixar-AI/mixar-backend#2023); the next planned release containing them is still required:

- Tool `title`s (policy 5.E): every Mixar tool gets a `title` and `annotations.title`, for every MCP client.
- AI image and video generation (policy 4.B): with `MIXAR_MCP_HIDE_MEDIA_GENERATION=1`, which `.mcp.json` sets, Mixar leaves `image_gen`, `depth_to_image`, `video_gen`, `video_upscale` and `brush_gen` out of its tools, descriptions and guide, refuses them (including from scripts), and does not offer `mixar_ui_act`. The script above refuses to start with a Mixar that predates this, so the plugin never runs with media generation available.

Until the Mixar release that carries those changes ships, the plugin does not start against an installed Mixar. The results above the launcher-script table were taken with Mixar 4.4.3, before that check existed.

## Not executed

- A model-driven Claude Code workflow on Windows (macOS passed above).
- A Cowork session on this computer.
- Linux plugin loading. The Windows plugin passed the current test above.
- Signed out, MCP turned off, and several Mixar apps open at once through this plugin. The launcher's handling of these states is shared with the Hermes and OpenAI packages, where it was tested.
- A successful developer-portal **Validate** and security scan. The initial
  repository-validation error and correction are recorded above.
