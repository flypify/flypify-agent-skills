# Perplexity

Perplexity paid plans can add custom remote connectors (MCP over Streamable HTTP). An organisation admin may need to enable them first.

1. Settings -> Connectors -> Add connector -> Custom -> Remote.
2. Name `Flypify`, URL `https://api.flypify.com/mcp/`, authentication OAuth (sign in with your Flypify account). If OAuth fails, choose API key and use `Authorization: Bearer flypify_live_...`.
3. Turn the connector on in a thread's sources/tools menu.
4. Paste `skills/flypify/SKILL.md` into a Space's instructions; upload the other `skills/flypify/*.md` files as Space files.
5. Test: "Use Flypify: check my account status and list my stores."

If your plan has no custom connectors, use Perplexity for research only and hand the plan to an agent that can call Flypify, or use the HTTP route (`generic-http.md`) from a script.
