#!/usr/bin/env bash
# Copy every skill in skills/ to .claude/skills/ (Claude Code) and
# .cursor/skills/ (Cursor). Both targets are git-ignored generated copies:
# edit skills/<name>/ and run this again. Safe to run any time; it also runs
# at every Claude Code session start (see .claude/settings.json).
#   --quiet   print nothing on success (used by the SessionStart hook)
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
QUIET=0
[[ "${1:-}" == "--quiet" ]] && QUIET=1

[[ -d "$ROOT/skills" ]] || { echo "sync-skill: no skills/ folder at $ROOT" >&2; exit 0; }

count=0
for target in "$ROOT/.claude/skills" "$ROOT/.cursor/skills"; do
  mkdir -p "$target" || continue
  for src in "$ROOT"/skills/*/; do
    [[ -d "$src" ]] || continue
    name="$(basename "$src")"
    rm -rf "${target:?}/$name"
    cp -R "$src" "$target/$name"
    [[ "$target" == "$ROOT/.claude/skills" ]] && count=$((count + 1))
  done
done

[[ "$QUIET" == "1" ]] || echo "Synced $count skill(s) to .claude/skills/ and .cursor/skills/."

# Agent team mode (see skills/flypify/agent-team.md): keep the specialists installed.
if [[ -f "$ROOT/.flypify-mode" ]] && grep -qx 'team' "$ROOT/.flypify-mode" 2>/dev/null; then
  if [[ "$QUIET" == "1" ]]; then bash "$ROOT/scripts/team.sh" --quiet; else bash "$ROOT/scripts/team.sh"; fi
fi
exit 0
