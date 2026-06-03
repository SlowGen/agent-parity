#!/usr/bin/env bash
# Apply agent-parity repo contents to global agent config directories.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false
AGENTS=""
SKIP_ECOSYSTEM=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Apply cursor/skills and cursor/rules from this repo to ~/.cursor/

Options:
  --dry-run           Show what rsync would do without changing files
  --agents LIST       Also mirror skills to comma-separated agent dirs
                      (claude, copilot, agents). Example: --agents claude,copilot
  --skip-ecosystem    Skip skills CLI install and ~/.cursor/skills symlinks
  -h, --help          Show this help

See AGENTS.md for full documentation.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --agents)
      AGENTS="${2:-}"
      shift 2
      ;;
    --skip-ecosystem)
      SKIP_ECOSYSTEM=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

RSYNC_OPTS=(-a)
if [[ "$DRY_RUN" == true ]]; then
  RSYNC_OPTS+=(-av --dry-run)
else
  RSYNC_OPTS+=(-av --delete)
fi

apply_dir() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ ! -d "$src" ]]; then
    echo "Skip $label: source missing ($src)"
    return 0
  fi

  mkdir -p "$dest"
  echo "==> $label"
  echo "    $src -> $dest"
  rsync "${RSYNC_OPTS[@]}" "$src/" "$dest/"
}

CURSOR_SKILLS="${HOME}/.cursor/skills"
CURSOR_RULES="${HOME}/.cursor/rules"

apply_dir "${REPO_ROOT}/cursor/skills" "${CURSOR_SKILLS}" "Cursor skills"
apply_dir "${REPO_ROOT}/cursor/rules" "${CURSOR_RULES}" "Cursor rules"

if [[ -n "$AGENTS" ]]; then
  IFS=',' read -ra AGENT_LIST <<<"$AGENTS"
  for agent in "${AGENT_LIST[@]}"; do
    agent="$(echo "$agent" | xargs)"
    case "$agent" in
      claude)
        apply_dir "${REPO_ROOT}/cursor/skills" "${HOME}/.claude/skills" "Claude skills (mirror)"
        ;;
      copilot)
        apply_dir "${REPO_ROOT}/cursor/skills" "${HOME}/.copilot/skills" "Copilot skills (mirror)"
        ;;
      agents)
        apply_dir "${REPO_ROOT}/cursor/skills" "${HOME}/.agents/skills" "Agents skills (mirror)"
        ;;
      *)
        echo "Unknown agent for --agents: $agent (use claude, copilot, or agents)" >&2
        exit 1
        ;;
    esac
  done
fi

if [[ "$SKIP_ECOSYSTEM" == false ]]; then
  ECOSYSTEM_ARGS=()
  if [[ "$DRY_RUN" == true ]]; then
    ECOSYSTEM_ARGS+=(--dry-run)
  fi
  "${REPO_ROOT}/scripts/ecosystem-skills.sh" "${ECOSYSTEM_ARGS[@]}"
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "Dry run complete (no files changed)."
else
  echo "Apply complete. Restart Cursor and check Settings → Rules."
fi
