#!/usr/bin/env bash
# Install (or remove) the Flypify agent team: ten specialists from team/.
#
#   ./scripts/team.sh            install: team/<name>.md ->
#                                  .claude/agents/flypify-<name>.md      (Claude Code subagents)
#                                  .claude/skills/flypify-<name>/SKILL.md (Claude Code skills)
#                                  .cursor/skills/flypify-<name>/SKILL.md (Cursor skills)
#                                and records "team" in .flypify-mode so sync-skill keeps them
#   ./scripts/team.sh --remove   back to a single agent: deletes those copies, records "single"
#   --quiet                      print nothing on success
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE=install
QUIET=0
for a in "$@"; do
  case "$a" in
    --remove) MODE=remove ;;
    --quiet) QUIET=1 ;;
  esac
done

say() { [[ "$QUIET" == "1" ]] || echo "$@"; }

[[ -d "$ROOT/team" ]] || { echo "team.sh: no team/ folder at $ROOT" >&2; exit 1; }

count=0
for src in "$ROOT"/team/*.md; do
  [[ -f "$src" ]] || continue
  base="$(basename "$src" .md)"
  [[ "$base" == "README" ]] && continue
  name="flypify-$base"
  if [[ "$MODE" == "remove" ]]; then
    rm -f "$ROOT/.claude/agents/$name.md"
    rm -rf "$ROOT/.claude/skills/$name" "$ROOT/.cursor/skills/$name"
  else
    mkdir -p "$ROOT/.claude/agents" "$ROOT/.claude/skills/$name" "$ROOT/.cursor/skills/$name"
    cp "$src" "$ROOT/.claude/agents/$name.md"
    cp "$src" "$ROOT/.claude/skills/$name/SKILL.md"
    cp "$src" "$ROOT/.cursor/skills/$name/SKILL.md"
  fi
  count=$((count + 1))
done

if [[ "$MODE" == "remove" ]]; then
  printf 'single\n' > "$ROOT/.flypify-mode"
  say "Removed $count Flypify specialists. Mode: single agent."
else
  printf 'team\n' > "$ROOT/.flypify-mode"
  say "Installed $count Flypify specialists (.claude/agents/, .claude/skills/, .cursor/skills/). Mode: agent team."
  say "Restart your agent once so it loads them. In Claude Code, /agents lists them."
fi
exit 0
