# Mixar for Claude

Connect Claude to [Mixar](https://www.mixar.app), the AI-native 3D editor built on Blender 5.2. With this plugin Claude can read and edit the 3D scene open in the Mixar desktop app, build objects step by step, apply realistic materials, generate 3D models, textures, rigs and animation, render previews and turntables, and export game-ready assets for Unity, Unreal and Godot.

The plugin has two parts:

- `.mcp.json` starts the MCP server that the Mixar desktop app installs for the signed-in user, through `scripts/mixar-mcp` (`scripts/mixar-mcp.cmd` on Windows).
- `skills/mixar` teaches Claude the Mixar workflow: check that Mixar is ready, read the scene, build in small steps, verify each change with a render, and deliver.

## Requirements

- The Mixar desktop app on macOS or Windows (Linux is expected to work but is not yet verified), with a Mixar account signed in and **Connect MCP** turned on. Both are done once in Mixar's interface.
- Claude running on the same computer as Mixar: Claude Code (terminal, IDE extensions or the desktop app's Code tab), or a Cowork session that runs on your computer. Chat on claude.ai, in the desktop app and on mobile does not start local MCP servers, so it cannot use this plugin.
- An internet connection: Mixar's tools run through Mixar's backend under your account.

You do not need a Mixar API key, a token or a separate Python or Node.js installation. The launcher runs on the Python that ships inside Mixar.

The plugin currently requires the development build from [client PR #2078](https://github.com/Mixar-AI/mixar-texture-painting/pull/2078) and a backend with [PR #2024](https://github.com/Mixar-AI/mixar-backend/pull/2024). The installed Mixar 4.4.3 release lacks the required media-generation restriction and the plugin refuses to start with it. See [Verification](VERIFICATION.md) for the tested builds and release limitation.

## Set up

1. Install Mixar from https://www.mixar.app, open it and sign in.
2. In Mixar, open the profile menu > **Connect MCP** and check that the status line reads "MCP is on".
3. Add this plugin in Claude, then start a new Claude Code session (or run `/mcp` and reconnect the `mixar` server).
4. Ask Claude: "Is Mixar ready? Check the connection without changing my scene."

To try a local copy of this repository in Claude Code, run `claude --plugin-dir /path/to/claude-mixar`.

If you added Mixar to Claude Code by hand before, remove that entry (`claude mcp remove mixar`) so each Mixar tool is listed once. [Setup and troubleshooting](skills/mixar/references/setup.md) covers the failure messages and what to do about each.

## Example prompts

- "Check whether Mixar is connected and summarize the current scene without changing it."
- "In a new scene tab, model a one-metre low-poly wooden crate with scripts, check its size and show me a preview."
- "Export the crate for Godot as a GLB to my Downloads folder and tell me whether the export verification passed."
- "Show me my Mixar credit balance and the options for turning a reference image into a 3D model. Don't generate anything yet."

## What Claude can do with it

| Area | Tools |
|------|-------|
| Readiness and guidance | `mixar_status`, `mixar_ui_context`, `mixar_guide`, `search_documentation` |
| Read the scene | `scene_overview`, `scene_hierarchy`, `get_object_details`, `inspect_geometry` |
| Build | `execute_bpy_script`, `move_groups`, `place_camera` |
| 3D generation | `get_generation_params`, `enqueue_generation`, `get_all_queue_status`, `poll_generation` |
| Assets and materials | `search_asset_library`, `list_terrain_assets`, `create_layered_material` |
| Verify | `render_viewport`, `view_image`, `inspect_uv_map`, `inspect_mesh_seams` |
| Deliver | `export_scene` (`unreal`, `unity`, `godot`, `web`, `ar` and `print` presets), `export_asset`, `render_scene_image`, `render_scene_video` |
| Scene tabs and projects | `mixar_scene_new`, `mixar_scenes`, `mixar_scene_switch`, `mixar_scene_close`, `mixar_projects`, `mixar_project_open` |
| Account | `mixar_credit_balance`, `mixar_tool_quote` |

The live tool list comes from the running Mixar app and can change between Mixar releases. Every tool declares whether it is read-only or can change your scene.

## What the plugin runs, sends and fetches

Read this before installing.

- **Runs a program from the installed Mixar app.** `scripts/mixar-mcp` is a short shell script that runs `~/.mixar/connector/mixar-mcp`, a launcher the Mixar desktop app writes for the current user. On Windows, `scripts/mixar-mcp.cmd` runs `%USERPROFILE%\.mixar\connector\mixar-mcp.cmd`. That launcher runs Mixar's bundled MCP server on Mixar's embedded Python. The plugin itself contains no compiled code, installs no packages and downloads nothing.
- **Runs Python inside Mixar.** `execute_bpy_script` and other scene tools run Python in the Mixar process with your user account's privileges. Mixar blocks some modules in these scripts, but a loopback connection is not a security sandbox.
- **Can start Mixar.** A tool call made while Mixar is closed may open the installed Mixar app, and Mixar stays open after Claude exits. Listing tools never starts Mixar.
- **Talks to Mixar over loopback, and Mixar talks to its backend.** The launcher connects to the desktop app on `127.0.0.1` with a per-launch token. The desktop app forwards tool calls to Mixar's backend (`api.mixar.app`) under your signed-in account.
- **Sends generation inputs to AI providers.** For an AI generation, Mixar's backend passes the prompt, reference images and relevant scene context to the provider that runs the chosen model (see the Privacy Policy section below).
- **Leaves out AI image and video generation.** `.mcp.json` sets `MIXAR_MCP_HIDE_MEDIA_GENERATION=1` for the server. Mixar then leaves AI image and video generation out of the tools, descriptions and guide it gives Claude, does not offer the tool that clicks in Mixar's interface, and refuses those jobs even when a script asks for them. 3D generation stays available. With a Mixar version that cannot do this, the plugin refuses to start and asks you to update Mixar.
- **Spends Mixar credits.** AI generation jobs and `create_layered_material` cost Mixar credits from your account; every other tool is free. `mixar_tool_quote` gives the current price before a call. The plugin cannot buy credits or change a subscription.
- **Reads outside the plugin folder.** The launcher reads `~/.mixar/` (its settings, the saved tool list and the discovery records of running Mixar apps). It never reads your Mixar login: the desktop app attaches its own sign-in to each call.
- **Reads two optional environment variables.** `MIXAR_MCP_LAUNCHER` makes the plugin run another launcher instead of Mixar's, and `MIXAR_MCP_DISCOVERY_DIR` points Mixar's launcher at another discovery folder. Both exist for testing development builds of Mixar; leave them unset for normal use.
- **Sends no analytics of its own.** The plugin collects nothing. Mixar's own usage analytics are described below.
- **Does not update itself.** New plugin versions arrive through the Claude plugin directory. Mixar updates through its own updater, outside this plugin.

## Privacy Policy

This plugin is an adapter: it stores no data and sends nothing itself. Everything it starts is part of the Mixar desktop app, which is covered by the [Mixar Privacy Policy](https://www.mixar.app/legal/privacy-policy). In summary:

- **Data collected.** When Claude calls a Mixar tool, Mixar receives the tool's inputs (including any prompts and scripts Claude writes), the scene data the tool needs, and its results. Mixar receives only the tool calls Claude makes, not your Claude conversation.
- **Use and storage.** Mixar's backend runs each tool call under your account and keeps a diagnostic record of it (inputs, prompts within them, results and technical context) for troubleshooting and service improvement. Mixar does not currently use your content or usage data to train or fine-tune AI models.
- **Sharing with third parties.** For a generation, Mixar's backend sends the prompt, reference images and relevant scene context to the AI provider or platform that runs the chosen model (such as OpenAI, Anthropic, Google, OpenRouter, fal.ai, Replicate, Tripo, Meshy or World Labs). Mixar does not sell your personal information.
- **Retention.** Mixar deletes diagnostic records of MCP tool calls within 30 days of collection, and their backup copies within 7 days of the backup's creation. Desktop usage analytics are kept for 30 days.
- **Usage analytics.** Mixar's desktop usage analytics are on by default and can be turned off under **Edit > Preferences > System > Privacy > Share Usage Data**. Turning them off does not stop the diagnostic records above.
- **Contact.** Privacy questions and deletion requests: support@mixar.app.

## Support

- Setup and troubleshooting: [skills/mixar/references/setup.md](skills/mixar/references/setup.md)
- Help, bug reports and security concerns: support@mixar.app or https://www.mixar.app/contact
- Source and issues: https://github.com/Mixar-AI/claude-mixar

## Platforms

| Platform | Status | Launcher the plugin starts |
|----------|--------|----------------------------|
| macOS | Verified in Claude Code with the development build above | `~/.mixar/connector/mixar-mcp` |
| Linux | Expected to work, not yet verified | `~/.mixar/connector/mixar-mcp` (written when Mixar first runs) |
| Windows | Verified in Claude Code with the development build above | `%USERPROFILE%\.mixar\connector\mixar-mcp.cmd` |

The same `.mcp.json` works on both verified platforms. Claude Code 2.1.322 resolves the extensionless `scripts/mixar-mcp` command to its `.cmd` counterpart on Windows.

## License

The plugin's scripts, skill and documentation are under the MIT license (see `LICENSE`). The Mixar icon in `assets/icon.png` is a Mixar brand asset under `licenses/LicenseRef-Mixar-Brand.txt`; the MIT license grants no rights to Mixar's names or logos. Mixar itself is a separate product under its own license. Mixar is made by Adeveda Enterprises Private Limited.
