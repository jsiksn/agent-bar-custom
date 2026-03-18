# AgentBar

A macOS menu bar app that shows Claude Code and Codex 5-hour and weekly usage at a glance.

AgentBar renders separate menu bar items for Claude and Codex, each with a compact progress bar. Clicking either item opens a detailed popover with account-wide usage, reset times, and this-Mac-only session summaries.

## Features

- Separate menu bar indicators for Claude and Codex
- 5-hour session and weekly limit progress bars
- Detailed popovers with plan, reset times, today/month local totals, and recent sessions
- Adjustable refresh interval with manual refresh
- Lightweight accessory app with no Dock icon

## Requirements

- macOS 14 or later
- Swift 6.2 or later
- Claude Code installed and logged in
- Codex CLI installed and logged in

## How It Works

### Account-wide usage

- Claude: reads local Claude OAuth credentials from macOS Keychain or `~/.claude/.credentials.json`, then calls the Anthropic OAuth usage endpoint
- Codex: calls `codex app-server` and reads `account/rateLimits/read`

### This-Mac details

- Claude: scans `~/.claude/projects/**/*.jsonl`
- Codex: reads `~/.codex/logs_1.sqlite` and `~/.codex/state_5.sqlite`

This means the menu bar percentages are account-wide, while the lower detail cards are local-machine summaries only.

## Quick Start

```bash
git clone https://github.com/chenjingdev/AgentBar.git
cd AgentBar
swift build
./.build/debug/AgentBar
```

## Usage

1. Launch `AgentBar`.
2. Look for two menu bar items:
   - `CL` for Claude
   - `CX` for Codex
3. Check the compact bar and percentage in the menu bar.
4. Click an item to open its detailed popover.
5. Use `Settings` to change the refresh interval or trigger `Refresh Now`.

## Notes

- Claude usage is cached briefly to avoid temporary rate limits from the Anthropic endpoint.
- Local summaries can differ from the top percentage when you also use Claude or Codex on other machines.
- AgentBar does not require pasting browser cookies into the app.
- Upstream APIs and CLI protocols may change, so provider integrations may need maintenance over time.

## Privacy

- No telemetry or analytics are built in.
- Credentials are read from the local machine only.
- Claude usage cache and launch logs are stored under `~/.agentbar/`.

## Development

```bash
swift package clean
swift build
```
