# Cursor

1. Create a key at flypify.com/account ("AI agent access (MCP)") and export it as `FLYPIFY_API_KEY` in the shell that launches Cursor.
2. Add to `~/.cursor/mcp.json` (all projects) or `.cursor/mcp.json` (one project; do not commit a key):

```json
{
  "mcpServers": {
    "flypify": {
      "url": "https://api.flypify.com/mcp/",
      "headers": { "Authorization": "Bearer ${env:FLYPIFY_API_KEY}" }
    }
  }
}
```

3. Settings -> MCP: check `flypify` shows green with its tools.
4. Add the skill as a rule: copy `skills/flypify/SKILL.md` to `.cursor/rules/flypify.mdc` (add `description` and `alwaysApply: false` in its frontmatter), and keep the other `skills/flypify/*.md` files in the repo so the agent can open them.
5. Test in Agent mode: "Use Flypify: check my account status and list my stores."

If your Cursor version does not expand `${env:...}`, paste the key directly in a user-level `~/.cursor/mcp.json` only.
