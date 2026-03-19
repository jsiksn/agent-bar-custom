# AgentBar

AgentBar is a macOS menu bar app for watching Claude Code and Codex usage at a glance.

It shows compact 5-hour usage bars in the menu bar, and opens a detailed popover when clicked. The top bars are account-wide. The lower `This Mac` details come from local logs on the current machine.

## What It Does

- Shows separate menu bar items for Claude and Codex
- Shows account-wide 5-hour and weekly usage percentages
- Shows reset times, plan name, and local `This Mac` summaries
- Hides providers that are not available on the current Mac
- Keeps the last known good usage when an upstream usage endpoint is temporarily unavailable

## What It Does Not Do

- It does not continuously “measure” usage in the background while the app is closed
- It does not create or need its own backend service
- It does not require browser cookies to be pasted into the app
- It does not merge local `This Mac` logs from multiple computers

When the app is running, it periodically refreshes account-wide usage and local summaries. When the app is closed, Claude Code and Codex usage still continue to accumulate normally on their own services, and AgentBar will pick up the latest state the next time it launches.

## Supported Providers

AgentBar treats Claude and Codex as optional providers.

- Claude appears only if local Claude credentials are detectable
- Codex appears only if a supported Codex CLI binary is detectable

If a provider is missing, AgentBar does not show its menu bar item.

## Requirements

- macOS 14 or later
- Swift 6.2 or later

Provider-specific requirements:

- Claude support:
  - Claude Code installed
  - Logged in with OAuth credentials available in macOS Keychain or `~/.claude/.credentials.json`
- Codex support:
  - Codex CLI installed
  - A supported `codex` binary available at one of:
    - `~/.bun/bin/codex`
    - `/opt/homebrew/bin/codex`
    - `/usr/local/bin/codex`
  - A supported `node` binary available at one of:
    - `~/.bun/bin/node`
    - `/opt/homebrew/bin/node`
    - `/usr/local/bin/node`
    - `/usr/bin/node`

If you install or log in to Claude Code or Codex after AgentBar is already running, restart AgentBar so provider detection runs again.

## Data Sources

### Account-wide usage

Claude:

- Reads Claude OAuth credentials from macOS Keychain or `~/.claude/.credentials.json`
- Calls `https://api.anthropic.com/api/oauth/usage`

Codex:

- Starts `codex app-server`
- Reads `account/rateLimits/read`

### Local `This Mac` details

Claude:

- Scans `~/.claude/projects/**/*.jsonl`

Codex:

- Reads `~/.codex/logs_1.sqlite`
- Reads `~/.codex/state_5.sqlite`

## Caching And Refresh Behavior

The app intentionally does not hit upstream usage endpoints on every UI update.

Claude:

- Uses a `claude-hud`-style cache and backoff strategy
- Success cache TTL: 60 seconds
- Failure cache TTL: 15 seconds
- `429 rate-limited` responses keep showing the last known good value
- If `Retry-After` is present, it is respected
- Otherwise rate-limited retries use exponential backoff from 60 seconds up to 5 minutes

Codex:

- Uses the same high-level idea as Claude for local caching
- Success cache TTL: 60 seconds
- Failure cache TTL: 15 seconds
- Keeps the last known good value when Codex rate limits cannot be read

This means:

- The menu bar number may be slightly stale by design
- A stale value is usually better than dropping to `0%` during transient upstream failures
- The timestamp in the popover is the timestamp of the last good data being shown

## Installation

```bash
git clone https://github.com/chenjingdev/AgentBar.git
cd AgentBar
swift build
```

## Running

Run the debug binary directly:

```bash
./.build/debug/AgentBar
```

On first launch:

- The menu bar may briefly show `0%` placeholders while the first refresh runs
- After a few seconds, available providers should update to their real values

## Using The App

1. Launch `AgentBar`.
2. Look at the macOS menu bar.
3. Available providers appear as compact items:
   - `CL` for Claude
   - `CX` for Codex
4. The small bar and percentage show the current 5-hour usage.
5. Click a provider to open its detailed popover.
6. In the popover you can inspect:
   - 5-hour usage
   - weekly usage
   - reset times
   - plan name
   - `This Mac Today`
   - `This Mac Month`
   - recent local sessions
7. Open `Settings` to change refresh interval or run a manual refresh.

## Interpreting The Numbers

There are two different classes of numbers in the UI.

Top bars:

- Account-wide
- Queried from Claude or Codex directly
- Reflect usage across machines for the same account

Lower `This Mac` sections:

- Local-machine only
- Derived from logs stored on the current Mac
- Do not include activity from your other computers

Because of that, the detailed local summaries can differ from the top percentage if you also use Claude Code or Codex on another machine.

## Provider Detection Rules

Claude is considered available when at least one of these is true:

- A Claude credentials file exists at `~/.claude/.credentials.json`
- Claude credentials can be found in macOS Keychain

Codex is considered available when:

- A supported `codex` executable is found in one of the supported locations

If a provider is not available at launch time, AgentBar hides it completely instead of showing a broken or empty menu bar item.

## Privacy And Safety

- No telemetry or analytics are built in
- Credentials are read only from local machine sources
- AgentBar does not require browser cookies
- Claude and Codex usage caches are stored under `~/.agentbar/`

Current cache files:

- `~/.agentbar/claude-usage-cache.json`
- `~/.agentbar/codex-rate-limits-cache.json`

If you previously configured launch logs or manual run logs locally, they may also be stored under `~/.agentbar/`.

## Troubleshooting

### A provider does not appear

Claude:

- Make sure Claude Code is installed
- Make sure you are logged in
- Confirm credentials exist in Keychain or `~/.claude/.credentials.json`
- Restart AgentBar after logging in

Codex:

- Make sure Codex CLI is installed
- Make sure the `codex` executable exists in one of the supported paths
- Make sure `node` exists in one of the supported paths
- Restart AgentBar after installing or logging in

### A provider appears but the number looks stale

- Open the popover and check the update timestamp
- Upstream endpoints may be temporarily unavailable or rate-limited
- Claude specifically uses backoff when the Anthropic usage endpoint returns `429`
- Manual refresh is available, but repeatedly forcing refresh is not useful when the upstream service is already rate-limiting

### The top percentage does not match the lower token summaries

That is expected when:

- you use the same account on multiple Macs
- you used the service recently on another machine
- local logs are incomplete or unavailable on the current machine

## Development

Clean and rebuild:

```bash
swift package clean
swift build
```

Run after rebuilding:

```bash
./.build/debug/AgentBar
```

## Current Limitations

- Provider detection runs at launch time, not continuously
- Claude account-wide usage depends on the Anthropic OAuth usage endpoint being available
- Codex account-wide usage depends on `codex app-server` staying compatible with the current CLI
- The app is intentionally conservative about refresh frequency, so instantaneous updates are not the goal
