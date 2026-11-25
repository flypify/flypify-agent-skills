#!/usr/bin/env bash
# First-run setup for the Flypify agent skill pack.
#
#   1. asks for your Flypify API key (hidden input) and checks its shape
#   2. verifies it against the Flypify Agent API (free calls, no credits)
#   3. saves it to .env (FLYPIFY_API_KEY=...), readable only by you
#   4. creates MASTER_CONTEXT.md from the template if it is missing
#   5. copies skills/ into .claude/skills/ and .cursor/skills/
#   6. asks: single agent or agent team (--single / --team skip the question)
#
# The key is never printed, never passed on a command line and never logged.
# Re-run with --force to replace a key that is already saved.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API="${FLYPIFY_API_BASE:-https://api.flypify.com/api/v1}"
FORCE=0
MODE_ARG=""
for a in "$@"; do
  case "$a" in
    --force) FORCE=1 ;;
    --team) MODE_ARG=team ;;
    --single) MODE_ARG=single ;;
  esac
done

echo "=== Flypify agent skill pack: setup ==="
echo ""

# -- helpers ------------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }
have curl || { echo "curl is required (macOS and Git for Windows ship it; on Linux: apt install curl)."; exit 1; }

PY=""
for c in python3 python; do
  if have "$c" && "$c" -c "import json" >/dev/null 2>&1; then PY="$c"; break; fi
done

# json_get <file> <expr>  expr is "plan" or "stores_count"
json_get() {
  local file="$1" what="$2"
  if have jq; then
    case "$what" in
      plan) jq -r '.plan // empty' "$file" 2>/dev/null ;;
      stores_count) jq -r '(.stores // []) | length' "$file" 2>/dev/null ;;
      error_code) jq -r '.error.code // .error // empty' "$file" 2>/dev/null ;;
    esac
  elif [[ -n "$PY" ]]; then
    "$PY" -I -c '
import json,sys
try:
    d=json.load(open(sys.argv[1],encoding="utf-8"))
except Exception:
    sys.exit(0)
w=sys.argv[2]
if w=="plan": print(d.get("plan","") or "")
elif w=="stores_count": print(len(d.get("stores") or []))
elif w=="error_code":
    e=d.get("error")
    print(e.get("code","") if isinstance(e,dict) else (e or ""))
' "$file" "$what" 2>/dev/null
  else
    case "$what" in
      plan) sed -n 's/.*"plan"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$file" | head -1 ;;
      error_code) sed -n 's/.*"code"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$file" | head -1 ;;
      stores_count) echo "?" ;;
    esac
  fi
}

TMPDIR_SETUP="$(mktemp -d 2>/dev/null || mktemp -d -t flypify)"
cleanup() { rm -rf "$TMPDIR_SETUP"; }
trap cleanup EXIT

# api_get <path> <outfile>  -> prints the HTTP status (000 = no connection).
# The header goes to curl on stdin, so the key never shows up in `ps`.
api_get() {
  local path="$1" out="$2" c=""
  c="$(printf 'Authorization: Bearer %s\n' "$KEY" \
    | curl -sS -m 20 -o "$out" -w '%{http_code}' -H @- "$API$path" 2>/dev/null)" || true
  c="${c: -3}"
  echo "${c:-000}"
}

# -- step 1: the key ----------------------------------------------------------
KEY=""
if [[ -f "$ROOT/.env" ]] && grep -q '^FLYPIFY_API_KEY=flypify_live_' "$ROOT/.env" && [[ "$FORCE" == "0" ]]; then
  echo ".env already holds a Flypify key. Checking it (run with --force to replace it)."
  KEY="$(sed -n 's/^FLYPIFY_API_KEY=//p' "$ROOT/.env" | head -1 | tr -d '\r"'"'"' ')"
  SAVE=0
else
  echo "You need a Flypify plan and an API key:"
  echo "  1. Pick a plan:   https://flypify.com/pricing"
  echo "  2. Create a key:  https://flypify.com/account  ->  \"AI agent access (MCP)\""
  echo "     It starts with flypify_live_ . Treat it like a password."
  echo ""
  printf "Paste your key (input hidden, Enter to skip): "
  IFS= read -rs KEY || true
  printf "\n"
  KEY="$(printf '%s' "$KEY" | tr -d '\r\n\t ')"
  SAVE=1
fi

if [[ -z "$KEY" ]]; then
  echo "Skipped. Run ./scripts/setup.sh again when you have a key."
  SKIP_KEY=1
else
  SKIP_KEY=0
  if [[ ! "$KEY" =~ ^flypify_live_[A-Za-z0-9_-]+$ ]]; then
    echo "That doesn't look like a Flypify key (it should start with flypify_live_). Nothing was saved."
    unset KEY
    exit 1
  fi
fi

# -- step 2: verify (free: /me and /stores cost no credits or reveals) -------
if [[ "$SKIP_KEY" == "0" ]]; then
  echo "Checking the key with Flypify ..."
  ME="$TMPDIR_SETUP/me.json"
  code="$(api_get /me "$ME")"
  case "$code" in
    200)
      plan="$(json_get "$ME" plan)"
      ST="$TMPDIR_SETUP/stores.json"
      scode="$(api_get /stores "$ST")"
      stores="?"
      [[ "$scode" == "200" ]] && stores="$(json_get "$ST" stores_count)"
      echo "OK. Plan: ${plan:-unknown}. Stores: ${stores:-?}."
      ;;
    401)
      ecode="$(json_get "$ME" error_code)"
      echo "Flypify rejected that key (401${ecode:+ $ecode}). It may be mistyped, revoked or deleted."
      echo "Create a new one at https://flypify.com/account -> \"AI agent access (MCP)\". Nothing was saved."
      unset KEY
      exit 1
      ;;
    402|403)
      ecode="$(json_get "$ME" error_code)"
      echo "The key works but the account has no active paid plan (${code}${ecode:+ $ecode})."
      echo "Pick a plan at https://flypify.com/pricing, then run this again. Nothing was saved."
      unset KEY
      exit 1
      ;;
    000)
      echo "Could not reach Flypify (offline or blocked). Saving the key anyway; run this again to check it."
      ;;
    *)
      echo "Flypify answered HTTP $code. Saving the key anyway; run this again later to check it."
      ;;
  esac

  # -- step 3: save to .env --------------------------------------------------
  if [[ "$SAVE" == "1" ]]; then
    (
      umask 077
      tmp="$ROOT/.env.tmp.$$"
      if [[ -f "$ROOT/.env" ]]; then
        grep -v '^FLYPIFY_API_KEY=' "$ROOT/.env" > "$tmp" || true
      else
        : > "$tmp"
      fi
      printf 'FLYPIFY_API_KEY=%s\n' "$KEY" >> "$tmp"
      mv "$tmp" "$ROOT/.env"
    )
    chmod 600 "$ROOT/.env" 2>/dev/null || true
    echo "Saved to .env (git-ignored, owner-only where the file system allows it)."
  fi
  unset KEY
fi
echo ""

# -- step 4: MASTER_CONTEXT.md ------------------------------------------------
if [[ ! -f "$ROOT/MASTER_CONTEXT.md" ]]; then
  cp "$ROOT/MASTER_CONTEXT.template.md" "$ROOT/MASTER_CONTEXT.md"
  echo "Created MASTER_CONTEXT.md. Your agent fills it in as you work."
else
  echo "MASTER_CONTEXT.md already exists. Left as is."
fi

# -- step 5: skills -----------------------------------------------------------
bash "$ROOT/scripts/sync-skill.sh"
echo ""

# -- step 6: single agent or agent team ----------------------------------------
MODE="$MODE_ARG"
CURRENT=""
[[ -f "$ROOT/.flypify-mode" ]] && CURRENT="$(head -1 "$ROOT/.flypify-mode" | tr -d ' ')"
if [[ -z "$MODE" && -n "$CURRENT" ]]; then
  echo "Mode: $CURRENT (switch with ./scripts/team.sh or ./scripts/team.sh --remove)."
elif [[ -z "$MODE" && -t 0 ]]; then
  echo "How do you want to run Flypify?"
  echo "  1) Single agent: one agent runs the whole launch loop (default)"
  echo "  2) Agent team: a lead plus 10 specialists (Winners Research, Brand Spy, Supplier"
  echo "     Sourcing, Store Builder, Listicles, Static and Video Ad Studio, Meta Campaigns,"
  echo "     Split Tests, Store Insights)"
  printf "Choose 1 or 2 [1]: "
  read -r pick || pick=""
  if [[ "$pick" == "2" ]]; then MODE=team; else MODE=single; fi
elif [[ -z "$MODE" ]]; then
  echo "Mode not chosen yet: your agent will ask (single agent or agent team) on first use."
fi
if [[ "$MODE" == "team" ]]; then
  bash "$ROOT/scripts/team.sh"
elif [[ "$MODE" == "single" ]]; then
  if [[ "$CURRENT" == "team" ]]; then bash "$ROOT/scripts/team.sh" --remove; else printf 'single
' > "$ROOT/.flypify-mode"; echo "Mode: single agent. Switch any time with ./scripts/team.sh"; fi
fi
echo ""

cat <<'EOF'
Next steps
  Claude Code (loads the key from .env into the shell, then starts):
      set -a; . ./.env; set +a; claude
    Then run /mcp and check that "flypify" is connected.
  Codex:   see setup/chatgpt-and-codex.md
  Cursor:  export FLYPIFY_API_KEY the same way, then open this folder (see setup/cursor.md)

  First prompt to try:
    Use Flypify. Check my account and stores, then find 5 winners in {your niche}
    and tell me which one to launch.
EOF
