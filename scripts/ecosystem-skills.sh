#!/usr/bin/env bash
# Install ecosystem skills via the skills CLI and symlink them into ~/.cursor/skills/.
#
# Skills install to ~/.agents/skills/ (managed by npx skills). Cursor also reads
# ~/.cursor/skills/, so we mirror with symlinks after each apply. apply.sh runs
# rsync first (which may delete stale symlinks), then calls this script.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${REPO_ROOT}/cursor/ecosystem-skills.json"
DRY_RUN=false
SKIP_INSTALL=false
SKIP_LINK=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install ecosystem skills from cursor/ecosystem-skills.json and link them into
~/.cursor/skills/ for Cursor discovery.

Options:
  --dry-run         Print actions without installing or linking
  --skip-install    Only create ~/.cursor/skills symlinks
  --skip-link       Only run skills CLI install
  -h, --help        Show this help

See AGENTS.md#ecosystem-skills.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-install)
      SKIP_INSTALL=true
      shift
      ;;
    --skip-link)
      SKIP_LINK=true
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

if [[ ! -f "$MANIFEST" ]]; then
  echo "Skip ecosystem skills: manifest missing ($MANIFEST)"
  exit 0
fi

read_manifest() {
  python3 - "$MANIFEST" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

for package in data.get("packages", []):
    source = package["source"]
    skills = package.get("skills", "*")
    if skills == "*":
        print(f"PKG\t{source}\t*")
    elif isinstance(skills, list):
        for skill in skills:
            print(f"PKG\t{source}\t{skill}")
    else:
        print(f"PKG\t{source}\t{skills}")

link = data.get("linkToCursorSkills", {})
for prefix in link.get("prefixes", []):
    print(f"PREFIX\t{prefix}")
for name in link.get("names", []):
    print(f"NAME\t{name}")
PY
}

install_packages() {
  if [[ "$SKIP_INSTALL" == true ]]; then
    echo "Skip ecosystem skills install (--skip-install)"
    return 0
  fi

  if ! command -v npx >/dev/null 2>&1; then
    echo "Skip ecosystem skills install: npx not found (install Node.js or run with --skip-install)" >&2
    return 0
  fi

  local had_pkg=false
  while IFS=$'\t' read -r kind source skill; do
    [[ "$kind" == "PKG" ]] || continue
    had_pkg=true

    local cmd=(npx skills add "$source" -g -a cursor -y)
    if [[ "$skill" == "*" ]]; then
      cmd+=(--skill '*')
    else
      cmd+=(-s "$skill")
    fi

    if [[ "$DRY_RUN" == true ]]; then
      echo "==> Would install: ${cmd[*]}"
    else
      echo "==> Installing ecosystem skills: $source (${skill})"
      "${cmd[@]}"
    fi
  done < <(read_manifest)

  if [[ "$had_pkg" == false ]]; then
    echo "No packages listed in $MANIFEST"
  fi
}

link_to_cursor_skills() {
  if [[ "$SKIP_LINK" == true ]]; then
    echo "Skip ecosystem skills link (--skip-link)"
    return 0
  fi

  local agents_skills="${HOME}/.agents/skills"
  local cursor_skills="${HOME}/.cursor/skills"

  if [[ ! -d "$agents_skills" ]]; then
    echo "Skip ecosystem skills link: $agents_skills not found (run install first)"
    return 0
  fi

  mkdir -p "$cursor_skills"

  local linked=0
  local prefixes=()
  local names=()

  while IFS=$'\t' read -r kind value _rest; do
    case "$kind" in
      PREFIX) prefixes+=("$value") ;;
      NAME) names+=("$value") ;;
    esac
  done < <(read_manifest)

  link_skill() {
    local source_dir="$1"
    local name
    name="$(basename "$source_dir")"
    local target="${cursor_skills}/${name}"

    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "Skip link $name: real directory exists at $target (repo-managed skill)"
      return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
      echo "==> Would link: $target -> $source_dir"
    else
      ln -sfn "$source_dir" "$target"
      echo "==> Linked: $name -> $source_dir"
    fi
    linked=$((linked + 1))
  }

  for prefix in "${prefixes[@]}"; do
    shopt -s nullglob
    for skill_dir in "${agents_skills}/${prefix}"*; do
      [[ -d "$skill_dir" ]] || continue
      link_skill "$skill_dir"
    done
    shopt -u nullglob
  done

  for name in "${names[@]}"; do
    local skill_dir="${agents_skills}/${name}"
    if [[ -d "$skill_dir" ]]; then
      link_skill "$skill_dir"
    elif [[ "$DRY_RUN" == true ]]; then
      echo "==> Would link (after install): ${cursor_skills}/${name} -> ${skill_dir}"
    else
      echo "Skip link $name: not installed at $skill_dir"
    fi
  done

  if [[ "$linked" -eq 0 && "$DRY_RUN" == false ]]; then
    echo "No ecosystem skills linked (install packages first or check manifest)"
  fi
}

install_packages
link_to_cursor_skills

if [[ "$DRY_RUN" == true ]]; then
  echo "Ecosystem skills dry run complete."
fi
