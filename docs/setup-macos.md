# Setup on macOS

Use this when bringing a **new or empty** Mac up to match the Linux configuration.

## Prerequisites

- [Cursor](https://cursor.com/) installed
- Git
- Clone of this repo (see below)

## Steps

1. **Clone the repo**

   ```bash
   git clone https://github.com/slowgen/agent-parity.git ~/agent-parity
   cd ~/agent-parity
   ```

2. **Apply skills and rules**

   ```bash
   chmod +x scripts/apply.sh scripts/ecosystem-skills.sh
   ./scripts/apply.sh
   ```

   This copies repo skills/rules and installs Flutter/Dart ecosystem skills (needs `npx` / Node.js). Use `./scripts/apply.sh --skip-ecosystem` if you only want repo-owned skills.

3. **Sign in to Cursor**

   Use the same account as your other machine so built-in skills under `~/.cursor/skills-cursor/` can sync.

4. **MCP (manual)**

   - Copy structure from `cursor/mcp.json.example`
   - Merge into `~/.cursor/mcp.json` with your API keys and paths
   - Do not commit secrets to the repo

5. **User Rules (if any)**

   Cursor **User Rules** in Settings are not stored in this repo. Re-enter them in **Cursor → Settings → Rules** if you use them.

6. **Verify**

   - Open **Cursor → Settings → Rules** (Cmd+Shift+J)
   - Confirm global rules and skills from this repo appear
   - Run through the checklist in [AGENTS.md](../AGENTS.md#verification-checklist)

## After updates

```bash
cd ~/agent-parity
git pull
./scripts/apply.sh
```

Restart Cursor if changes do not appear immediately.
