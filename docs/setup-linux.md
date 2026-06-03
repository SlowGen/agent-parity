# Setup on Linux

Linux was the **source** machine used to bootstrap this repo. Use this doc to refresh from the repo or to **capture** new local changes back into Git.

## Apply from repo (normal sync)

```bash
cd /path/to/agent-parity
git pull
./scripts/apply.sh
```

This updates `~/.cursor/skills/` and `~/.cursor/rules/` to match the repo, then installs and links ecosystem skills (Flutter, Dart) from `cursor/ecosystem-skills.json`.

Repo-owned skills only (skip ecosystem install):

```bash
./scripts/apply.sh --skip-ecosystem
```

## Capture local changes into the repo

When you create or edit config under your home directory:

### New or updated skill

```bash
SKILL=my-new-skill
cp -R ~/.cursor/skills/"$SKILL" /path/to/agent-parity/cursor/skills/
cd /path/to/agent-parity
git add cursor/skills/"$SKILL"
git commit -m "Add skill $SKILL"
git push
```

### New or updated global rule

```bash
RULE=my-rule.mdc
cp ~/.cursor/rules/"$RULE" /path/to/agent-parity/cursor/rules/
cd /path/to/agent-parity
git add cursor/rules/"$RULE"
git commit -m "Add rule $RULE"
git push
```

### What not to capture

- Do **not** copy from `~/.cursor/skills-cursor/`
- Do **not** commit `~/.cursor/mcp.json` (use `cursor/mcp.json.example` for structure only)

## Verify

```bash
ls ~/.cursor/skills
ls ~/.cursor/rules
diff -rq cursor/skills ~/.cursor/skills
diff -rq cursor/rules ~/.cursor/rules
```

See [AGENTS.md](../AGENTS.md#verification-checklist) for the full checklist.
