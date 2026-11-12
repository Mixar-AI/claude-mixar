# Setting up Mixar for Claude

Installation, MCP availability and scene readiness are separate states. Check each in order.

## 1. Install Mixar

Download Mixar from https://www.mixar.app and open it once.

- macOS: move `Mixar.app` to `/Applications` or `~/Applications`.
- Windows: run Mixar's installer, then open Mixar once so it writes `%USERPROFILE%\.mixar\connector\mixar-mcp.cmd`.
- Linux: Mixar is a portable archive with no fixed folder. Open Mixar once so it writes its launcher.

Mixar updates itself; the plugin never downloads or updates Mixar.

## 2. Sign in and turn on MCP

1. Open Mixar and sign in from the profile menu.
2. Open the profile menu > **Connect MCP**.
3. The status line should read "MCP is on · AI apps can connect to this Mixar". If it says MCP is off, click **Turn on**.
4. Optional: switch on **Let AI apps control Mixar's interface**. Through this plugin Claude can then look at Mixar's interface (`mixar_ui_observe`, `mixar_ui_wait`), but `mixar_ui_act`, which clicks and types, is not offered, because the interface includes Mixar's image and video generators.

Mixar writes the launcher this plugin starts, `~/.mixar/connector/mixar-mcp` (on Windows, `%USERPROFILE%\.mixar\connector\mixar-mcp.cmd`), while it runs; with MCP off the launcher only answers that MCP is turned off. If that file is missing after these steps, quit and reopen Mixar.

## 3. Reconnect in Claude Code

Run `/mcp` in Claude Code, select the `mixar` server and reconnect it, or start a new session. Then call `mixar_status` (or `mixar_ui_context` when `mixar_status` is not listed yet): an answer naming the desktop and the scene means Mixar is ready.

If `/mcp` shows the `mixar` server as failed, the launcher did not start. A message that this Mixar version cannot run with Claude yet means the installed Mixar predates the plugin's support: update Mixar, open it once, and reconnect. The server's details in `/mcp`, or a session started with `claude --debug`, show the launcher's own message, such as the path where it looked for Mixar's launcher.

If you also added Mixar by hand earlier (for example with `claude mcp add mixar …`), remove that entry with `claude mcp remove mixar`, so that each Mixar tool is listed once.

## Development and QA builds

`MIXAR_MCP_LAUNCHER` points the plugin at another launcher (for example a source build's), and `MIXAR_MCP_DISCOVERY_DIR` at another discovery folder. Set them in the shell that starts Claude Code; when unset, the defaults apply.

## Where it runs

Claude must run on the same computer as Mixar: the launcher only reaches the Mixar app on its own computer. The plugin's MCP server loads in Claude Code (terminal, IDE extensions and the desktop app's Code tab) and in Cowork sessions that run on your computer. Chat on claude.ai, in the desktop app and on mobile does not start local servers.
