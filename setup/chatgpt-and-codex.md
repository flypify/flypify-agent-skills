# ChatGPT and Codex

## Codex CLI / IDE

1. Create a key at flypify.com/account ("AI agent access (MCP)") and export it:

```bash
export FLYPIFY_API_KEY="flypify_live_..."
```

2. Add the server:

```bash
codex mcp add flypify --url https://api.flypify.com/mcp/ --bearer-token-env-var FLYPIFY_API_KEY
```

or in `~/.codex/config.toml`:

```toml
[mcp_servers.flypify]
url = "https://api.flypify.com/mcp/"
bearer_token_env_var = "FLYPIFY_API_KEY"
```

3. Give Codex the skill: clone this repo (the skill is in `skills/flypify/`) (or `~/.codex/skills/flypify/` if your Codex version supports skills) and add one line to `AGENTS.md`: `For any e-commerce, store, ad or product task, follow skills/flypify/SKILL.md.`
4. Test: "Use Flypify: check my account status and list my stores."

## ChatGPT (web / desktop)

1. Turn on developer mode (Settings -> Apps & Connectors -> Advanced), then Create connector.
2. Name `Flypify`, MCP server URL `https://api.flypify.com/mcp/`, authentication OAuth. Sign in with your Flypify account.
3. Paste `skills/flypify/SKILL.md` into a Project's instructions or a custom GPT's instructions; upload the other `skills/flypify/*.md` files as knowledge.
4. In a chat, enable the Flypify connector from the tools menu.

If your ChatGPT plan cannot add custom connectors, build a custom GPT with an Action instead: import `https://api.flypify.com/api/v1/openapi.json`, authentication API key, type Bearer, and paste your key there (see `generic-http.md`).
