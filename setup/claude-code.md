# Claude Code

1. Create a key at flypify.com/account, "AI agent access (MCP)". It starts with `flypify_live_`.
2. Put it in an environment variable (never in a file you commit):

```bash
export FLYPIFY_API_KEY="flypify_live_..."
```

3. Add the server (keep the trailing slash):

```bash
claude mcp add --transport http flypify https://api.flypify.com/mcp/ \
  --header "Authorization: Bearer $FLYPIFY_API_KEY"
```

4. Install the skill: copy the `skills/flypify/` folder from this repo to `~/.claude/skills/flypify/` (all projects) or `.claude/skills/flypify/` (one project).
5. Restart Claude Code, run `/mcp` and check `flypify` is connected.
6. Test: "Use Flypify: check my account status and list my stores."

Alternative header: `X-Flypify-Key: flypify_live_...` works too.

## Using this repo instead

If you cloned this repo, steps 3 and 4 are done for you: `.mcp.json` declares the server (it expands `${FLYPIFY_API_KEY:-}` from the environment; unset means every call answers 401) and `scripts/setup.sh` saves your key to `.env` and syncs the skill. Start Claude Code with the key loaded:

```bash
set -a; . ./.env; set +a; claude
```
