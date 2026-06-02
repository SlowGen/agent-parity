# agent-parity

Dotfiles for **global** AI agent configuration: personal Cursor skills, global rules, and documented MCP setup. One Git repo keeps Mac, Linux, and other machines aligned.

**Full instructions:** see [AGENTS.md](AGENTS.md).

## Quick start

```bash
git clone https://github.com/slowgen/agent-parity.git ~/agent-parity
cd ~/agent-parity
./scripts/apply.sh
```

Restart Cursor and check **Settings → Rules**.

## What is synced

- `cursor/skills/` → `~/.cursor/skills/`
- `cursor/rules/` → `~/.cursor/rules/`

Cursor-managed `~/.cursor/skills-cursor/` is intentionally **not** in this repo.

## Updating

```bash
git pull
./scripts/apply.sh
```

After local edits, copy changes into `cursor/` and commit. See [AGENTS.md](AGENTS.md#capture-workflow-local-changes--repo).
