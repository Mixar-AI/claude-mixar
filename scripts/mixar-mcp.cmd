@echo off
rem Start the MCP launcher that the Mixar desktop app installs for the current
rem user. Windows counterpart of scripts/mixar-mcp: .mcp.json names
rem scripts/mixar-mcp, which Windows resolves to this file through PATHEXT.
rem stdout carries MCP messages only; every message here goes to stderr.
rem MIXAR_MCP_LAUNCHER, when set, names another launcher (a development or QA
rem build of Mixar). Leave it unset for normal use. No parenthesised blocks:
rem a path such as "Program Files (x86)" would end one early.
setlocal
set "LAUNCHER=%MIXAR_MCP_LAUNCHER%"
if not "%LAUNCHER%"=="" goto check
if "%USERPROFILE%"=="" goto nohome
set "LAUNCHER=%USERPROFILE%\.mixar\connector\mixar-mcp.cmd"

:check
if not exist "%LAUNCHER%" goto missing
rem The plugin must not offer AI image or video generation. .mcp.json sets
rem MIXAR_MCP_HIDE_MEDIA_GENERATION=1, which only Mixar versions that list
rem "hide_media_generation" in the launcher's installation record honour; an
rem older Mixar would ignore it, so refuse to start instead.
for %%I in ("%LAUNCHER%") do set "RECORD=%%~dpIinstallation.json"
findstr /l /c:"hide_media_generation" "%RECORD%" >nul 2>&1 || goto old
call "%LAUNCHER%" %*
exit /b %ERRORLEVEL%

:nohome
>&2 echo mixar-mcp: USERPROFILE is not set, so Mixar's launcher cannot be found.
exit /b 1

:missing
>&2 echo mixar-mcp: Mixar's MCP launcher was not found at %LAUNCHER%.
>&2 echo Install Mixar from https://www.mixar.app, open it, sign in, and turn on
>&2 echo profile menu ^> Connect MCP. Then reconnect the server from /mcp in Claude Code.
exit /b 1

:old
>&2 echo mixar-mcp: this Mixar version cannot run with Claude yet.
>&2 echo Update Mixar to the latest version and open it once. Then reconnect the server
>&2 echo from /mcp in Claude Code.
exit /b 1
