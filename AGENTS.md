# Agent instructions

This repository turns an AI agent (Codex, Claude Code, Cursor, or any agent that reads `AGENTS.md`) into an e-commerce operator on Flypify: winners, supplier, store, listicle, static and video ads, Meta campaign. Everything runs through Flypify agent capabilities, reached over MCP (`https://api.flypify.com/mcp/`, keep the trailing slash) or the HTTP Agent API (`https://api.flypify.com/api/v1`).

## Where things are

| Path | What it is |
|---|---|
| `skills/flypify/SKILL.md` | **Read first.** The launch loop, plan limits, money rules, calling patterns, error playbook. |
| `skills/flypify/stores.md` | Building a store or product page. |
| `skills/flypify/listicles.md` | Writing a pre-sell article. |
| `skills/flypify/statics.md` | Briefing static image ads. |
| `skills/flypify/brand-spy.md` | Reverse-engineering a competitor. |
| `skills/flypify/agent-team.md` | Agent team mode: the lead's playbook, roster and handoff format. |
| `team/` | The ten specialist agents (installed by `scripts/team.sh` when the human picks agent team). |
| `prompts/PROMPT-PACK.md` | 25 example requests and what each should produce. |
| `setup/` | How to connect each client. |
| `MASTER_CONTEXT.md` | The human's workspace memory (git-ignored). |
| `logs/` | Call log for paid capabilities (git-ignored `.jsonl`). |

`.claude/skills/` and `.cursor/skills/` are generated copies of `skills/` (run `scripts/sync-skill.sh`). Edit `skills/`, never the copies.

## First-time setup

If `.env` or `MASTER_CONTEXT.md` is missing, tell the human to run `./scripts/setup.sh` (macOS, Linux, Git Bash) or `powershell -ExecutionPolicy Bypass -File scripts\setup.ps1` (Windows). Never ask the human to paste the key into chat.

## Loading the key

The key lives in `.env` as `FLYPIFY_API_KEY=flypify_live_...`. Clients read it from the environment, not from the file:

- **Codex:** `codex mcp add flypify --url https://api.flypify.com/mcp/ --bearer-token-env-var FLYPIFY_API_KEY`, with the variable exported in the shell that starts Codex (`set -a; . ./.env; set +a`).
- **Claude Code:** `.mcp.json` expands `${FLYPIFY_API_KEY:-}` from the environment; start Claude Code from a shell where it is exported. A 401 from the server means it wasn't.
- **Scripts / HTTP:** send `Authorization: Bearer $FLYPIFY_API_KEY` (or `X-Flypify-Key`).

Never print, echo, log or commit the key. Never read `.env` aloud or quote it in a reply.

## Every session

0. First connection only: if no mode is recorded (`Mode:` in `MASTER_CONTEXT.md`, or `.flypify-mode`), ask the human: **single agent or agent team?** For a team, run `./scripts/team.sh` (PowerShell `scripts	eam.ps1`) and act as the lead in `skills/flypify/agent-team.md`.
1. Read `MASTER_CONTEXT.md`. Use its defaults (niche, margin, stores, voice) instead of asking again.
2. Follow `skills/flypify/SKILL.md` step 0: `account_status`, `flypify_capabilities`, `stores_list`, then one line to the human: plan, stores used vs allowed, reveals left, whether spend is open.
3. If a `MASTER_CONTEXT.md` field is empty and you need it, ask once and write the answer back.
4. After meaningful work, add a dated Changelog line to `MASTER_CONTEXT.md` (store ids, product, what changed).

## Money rules (never skip)

- **Quote every credit or ad spend with the number and wait for an explicit yes** in this conversation: `statics_quote`, `video_quote`, `listicles_quote`, `campaigns.launch_preview`. `pages.build` has no quote endpoint: state about 80 credits and ask.
- Pass the quote back (`expected_credits`). On `409 price_changed`, quote again and ask again.
- **Nothing goes live without a yes:** publishing a product or listicle, launching or resuming a campaign, applying a split-test winner.
- **Launching a campaign from an agent needs the Scale plan.** On Starter and Growth, build the campaign draft and the human launches it in the Flypify app. `agent_spend_disabled` also means: the human runs that step in the app.
- Use `dry_run: true` first where it exists and show the diff.
- Never invent reviews, ratings, counts, experts, press logos or countdowns. Never copy another brand's name, photos or words.
- After every paid call, append one line to `logs/flypify-calls.jsonl` (format in `logs/README.md`).

## Updating

If the session banner says the repo is behind, tell the human to run `git pull`. Don't pull on their behalf.
