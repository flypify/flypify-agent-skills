# Flypify agent skills: session rules

- **Skill:** `.claude/skills/flypify/SKILL.md` (synced from `skills/flypify/`). Read the companion file for the step you are on: `stores.md`, `listicles.md`, `statics.md`, `brand-spy.md`.
- **Mode:** on first connection ask the human once: single agent or agent team (`skills/flypify/agent-team.md`). Team: run `./scripts/team.sh`, restart, and act as the lead; the specialists are Claude Code subagents named `flypify-*` (`/agents`).
- **Memory:** read `MASTER_CONTEXT.md` at the start of every session and write learnings and a dated Changelog line back. If it is missing, copy `MASTER_CONTEXT.template.md` to `MASTER_CONTEXT.md`.
- **Connection:** the `flypify` MCP server is in `.mcp.json` and reads `FLYPIFY_API_KEY` from the environment. If `/mcp` shows it failing or calls answer 401, the human should quit and restart with `set -a; . ./.env; set +a; claude`. If `.env` is missing, tell them to run `./scripts/setup.sh`.
- **Money:** quote every credit or ad spend with the number and wait for a yes. Nothing goes live without a yes. Agent launches need the Scale plan; otherwise build the draft and the human launches it in the app.
- **Logging:** append one JSONL line per paid call to `logs/flypify-calls.jsonl` (see `logs/README.md`).
- **Never** print or echo the API key, and never read `.env` into the conversation.
- Full agent rules: [AGENTS.md](AGENTS.md).
