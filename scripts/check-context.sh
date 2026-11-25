#!/usr/bin/env bash
# Claude Code SessionStart banner. Its output goes into the session context and
# to your terminal, so you and the agent both know where things stand:
#   - which skills are installed
#   - whether .env holds a key and whether this session can see it
#   - whether MASTER_CONTEXT.md exists
#   - whether the repo is behind its upstream (git fetch, 10 s ceiling)
# Informational only: never blocks, never pulls, always exits 0.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Run a command with a time limit, with or without coreutils `timeout`.
with_timeout() {
  local secs="$1"; shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@"
    return $?
  fi
  "$@" &
  local pid=$!
  ( sleep "$secs"; kill "$pid" 2>/dev/null ) >/dev/null 2>&1 &
  local watcher=$!
  wait "$pid" 2>/dev/null
  local rc=$?
  kill "$watcher" 2>/dev/null
  wait "$watcher" 2>/dev/null
  return $rc
}

# -- skills -------------------------------------------------------------------
skills=()
if [[ -d "$ROOT/.claude/skills" ]]; then
  for d in "$ROOT"/.claude/skills/*/; do
    [[ -f "$d/SKILL.md" ]] && skills+=("$(basename "$d")")
  done
fi

# -- key ----------------------------------------------------------------------
if [[ -f "$ROOT/.env" ]] && grep -q '^FLYPIFY_API_KEY=flypify_live_' "$ROOT/.env" 2>/dev/null; then
  env_line="ok   .env holds a Flypify key"
else
  env_line="--   .env missing or empty: run ./scripts/setup.sh"
fi
if [[ "${FLYPIFY_API_KEY:-}" == flypify_live_* ]]; then
  shell_line="ok   FLYPIFY_API_KEY is set in this session (.mcp.json can use it)"
else
  shell_line="--   FLYPIFY_API_KEY is not set in this session, so .mcp.json sends an empty key"
  shell_line+=$'\n'"     and every flypify call answers 401 (that 401 means: key not exported, not a bad key)."
  shell_line+=$'\n'"     Quit, then start with:  set -a; . ./.env; set +a; claude"
fi

if [[ -f "$ROOT/MASTER_CONTEXT.md" ]]; then
  ctx_line="ok   MASTER_CONTEXT.md (read it first, write learnings back)"
else
  ctx_line="--   MASTER_CONTEXT.md missing: copy MASTER_CONTEXT.template.md to MASTER_CONTEXT.md"
fi

# -- upstream -----------------------------------------------------------------
update_line=""
if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
   && git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
  GIT_TERMINAL_PROMPT=0 with_timeout 10 git -C "$ROOT" fetch origin --quiet >/dev/null 2>&1 || true
  upstream="$(git -C "$ROOT" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  [[ -z "$upstream" ]] && upstream="origin/main"
  if git -C "$ROOT" rev-parse --verify --quiet "$upstream" >/dev/null 2>&1; then
    behind="$(git -C "$ROOT" rev-list --count "HEAD..$upstream" 2>/dev/null || echo 0)"
    if [[ "$behind" =~ ^[0-9]+$ ]] && (( behind > 0 )); then
      update_line="$behind commit(s) behind $upstream: run git pull to update the skills."
    else
      update_line="Up to date with $upstream."
    fi
  fi
fi

# -- banner -------------------------------------------------------------------
{
  echo ""
  echo "-------------------------------------------------------------------"
  echo " Flypify agent skills: context check"
  echo "-------------------------------------------------------------------"
  if (( ${#skills[@]} > 0 )); then
    echo " Skills: ${skills[*]}  (in .claude/skills/)"
  else
    echo " Skills: none synced yet: run ./scripts/sync-skill.sh"
  fi
  echo " $env_line"
  echo " $shell_line"
  echo " $ctx_line"
  [[ -n "$update_line" ]] && echo " $update_line"
  echo ""
  echo " Start: skills/flypify/SKILL.md  |  Prompts: prompts/PROMPT-PACK.md"
  echo " Money rule: quote every credit or ad spend and wait for a yes."
  echo " Log every paid call to logs/flypify-calls.jsonl (see logs/README.md)."
  echo "-------------------------------------------------------------------"
} 2>/dev/null

exit 0
