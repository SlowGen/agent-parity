# Agent Parity

This repository is the **canonical source of truth** for global AI agent configuration: personal skills, Cursor rules, and documented MCP setup. Use it to keep **Mac and Linux** (and any future machine) aligned without copying Cursor-managed internals by hand.

After you apply this repo on a machine, `~/.cursor/skills/` and `~/.cursor/rules/` should match what is committed here.

## What this repo tracks

| In repo | Applied to (global) |
|---------|------------------------|
| `cursor/skills/` | `~/.cursor/skills/` |
| `cursor/rules/*.mdc` | `~/.cursor/rules/` |
| `cursor/ecosystem-skills.json` | Installed via `npx skills` → `~/.agents/skills/`, then symlinked to `~/.cursor/skills/` |
| `cursor/mcp.json.example` | Merged manually into `~/.cursor/mcp.json` |
| This file (`AGENTS.md`) | Instructions for humans and agents |

## What stays machine-local (do not commit)

| Path | Why |
|------|-----|
| `~/.cursor/skills-cursor/` | Cursor built-in and managed skills (auto-synced per machine) |
| `~/.cursor/plugins/`, `extensions/`, `projects/` | IDE state and marketplace plugins |
| `~/.cursor/mcp.json` | Contains secrets and machine-specific paths |
| Cursor **User Rules** (Settings) | Not stored on the filesystem; re-enter manually if needed |

**Rule for new personal skills:** always create them under `~/.cursor/skills/<name>/SKILL.md`, never under `~/.cursor/skills-cursor/`.

**Ecosystem skills** (official Flutter/Dart packages from GitHub) are listed in `cursor/ecosystem-skills.json` and installed by `./scripts/apply.sh` via the [skills CLI](https://skills.sh/). They live in `~/.agents/skills/` and are symlinked into `~/.cursor/skills/` so Cursor discovers them on both paths. Do not copy ecosystem skill content into `cursor/skills/` — update the manifest instead.

## Quick apply

From a clone of this repo:

```bash
./scripts/apply.sh
```

Dry run (show what would change):

```bash
./scripts/apply.sh --dry-run
```

Optional: mirror skills to other agents (only if you use them):

```bash
./scripts/apply.sh --agents claude,copilot
```

Skip ecosystem skill install/link (repo skills and rules only):

```bash
./scripts/apply.sh --skip-ecosystem
```

Restart Cursor after applying, then open **Settings → Rules** to confirm skills and rules appear.

## Ecosystem skills

Official Flutter, Dart, and helper skills are declared in `cursor/ecosystem-skills.json`. `./scripts/apply.sh` runs `./scripts/ecosystem-skills.sh`, which:

1. Installs packages with `npx skills add … -g -a cursor` (requires Node.js / `npx`)
2. Symlinks installed skills from `~/.agents/skills/` into `~/.cursor/skills/`

Run ecosystem steps alone:

```bash
./scripts/ecosystem-skills.sh              # install + link
./scripts/ecosystem-skills.sh --dry-run    # preview only
./scripts/ecosystem-skills.sh --skip-install   # link only (after manual install)
```

To add a new ecosystem package, edit `cursor/ecosystem-skills.json` and commit. Use `npx skills find` to discover packages on [skills.sh](https://skills.sh/).

Scripts are written for **macOS `/bin/bash` 3.2** (no empty-array expansion under `set -u`). If you use Homebrew bash, either works.

Current packages:

| Source | Skills |
|--------|--------|
| `flutter/skills` | All Flutter skills (`flutter-*`) |
| `dart-lang/skills` | All Dart skills (`dart-*`) |
| `vercel-labs/skills` | `find-skills` |

## Apply on a new machine (e.g. Mac)

1. Clone the repo:

   ```bash
   git clone https://github.com/slowgen/agent-parity.git ~/agent-parity
   cd ~/agent-parity
   ```

2. Run apply:

   ```bash
   ./scripts/apply.sh
   ```

3. Sign into Cursor so `~/.cursor/skills-cursor/` can populate with built-in/managed skills.

4. Merge MCP config by hand (see [MCP](#mcp-configuration)).

5. Run the [verification checklist](#verification-checklist).

See also [docs/setup-macos.md](docs/setup-macos.md).

## Refresh after repo changes

On any machine that already has a clone:

```bash
cd ~/agent-parity   # or your clone path
git pull
./scripts/apply.sh
```

Restart Cursor if skills or rules do not show up immediately.

## Capture workflow (local changes → repo)

When you add or edit a **personal** skill or global rule on one machine:

1. Copy into this repo:
   - `~/.cursor/skills/<name>/` → `cursor/skills/<name>/`
   - `~/.cursor/rules/<name>.mdc` → `cursor/rules/<name>.mdc`
2. Commit and push.
3. On other machines: `git pull && ./scripts/apply.sh`

Do **not** copy from `~/.cursor/skills-cursor/` into this repo.

See [docs/setup-linux.md](docs/setup-linux.md) for Linux-specific notes.

## Cursor-managed parity

Built-in and marketplace skills under `~/.cursor/skills-cursor/` are managed by Cursor. On a fresh Mac:

- Sign in to the same Cursor account.
- Install any managed skills you rely on (e.g. canvas, babysit) via Cursor Settings if they are missing.
- Do not duplicate those trees into this repo.

## MCP configuration

`cursor/mcp.json.example` documents the **shape** of MCP servers without secrets.

1. Open your local `~/.cursor/mcp.json` (create if missing).
2. Merge entries from the example; replace placeholders with your own API keys and paths.
3. Never commit `mcp.json` or real tokens to this repo.

## Cross-agent skill paths (optional)

Cursor also discovers skills from compatibility paths. This repo stores skills once under `cursor/skills/`. The apply script can mirror them when requested:

| Repo path | Global path |
|-----------|-------------|
| `cursor/skills/` | `~/.cursor/skills/` |
| (mirror) | `~/.agents/skills/` |
| (mirror) | `~/.claude/skills/` |
| (mirror) | `~/.copilot/skills/` |

## Verification checklist

- [ ] `ls ~/.cursor/skills` lists each folder under `cursor/skills/`
- [ ] `ls ~/.cursor/skills` includes `flutter-*` and `dart-*` symlinks (after ecosystem apply)
- [ ] `ls ~/.cursor/rules` lists each `.mdc` under `cursor/rules/`
- [ ] Cursor **Settings → Rules** shows global rules and skills
- [ ] A prompt that should trigger a skill (e.g. code review) loads the expected skill

## Instructions for AI agents

When the user asks to **sync**, **set up agent config**, or **apply agent-parity**:

1. Read this file (`AGENTS.md`) first.
2. Compare the repo to the machine:
   - `cursor/skills/` vs `~/.cursor/skills/`
   - `cursor/rules/` vs `~/.cursor/rules/`
3. Report drift (missing, extra, or differing files).
4. Run `./scripts/apply.sh` when the user wants the repo to win, or copy only **missing** files if local has newer edits the user wants to keep.
5. **Do not overwrite** local files without user confirmation if local modification time is newer than the repo copy.
6. Do not read or commit `~/.cursor/mcp.json`; refer only to `cursor/mcp.json.example` for structure.
7. Do not modify or copy `~/.cursor/skills-cursor/`.

## Repository layout

```
agent-parity/
├── AGENTS.md              # This playbook
├── README.md
├── cursor/
│   ├── skills/            # Personal global skills (repo-owned)
│   ├── rules/             # Global .mdc rules
│   ├── ecosystem-skills.json  # Flutter/Dart/etc. via skills CLI
│   └── mcp.json.example
├── docs/
│   ├── setup-macos.md
│   └── setup-linux.md
└── scripts/
    ├── apply.sh
    └── ecosystem-skills.sh
```
