# Claude.ai and Claude Desktop

Flypify's MCP server supports sign-in by URL (OAuth), so no key pasting is needed here.

1. Open Settings -> Connectors -> Add custom connector.
2. Name: `Flypify`. URL: `https://api.flypify.com/mcp/` (keep the trailing slash).
3. Click Connect and sign in with your Flypify account. You need a paid plan.
4. In a chat, open the tools menu and make sure Flypify is on.
5. Add the skill: Settings -> Capabilities -> Skills -> upload `flypify-skill.zip` (the `skills/flypify/` folder zipped). If your plan has no Skills, paste `skills/flypify/SKILL.md` into a Project's instructions and add the other `skills/flypify/*.md` files as Project knowledge.
6. Test: "Use Flypify: check my account status and list my stores."

Claude Desktop uses the same Connectors screen. On a team or enterprise plan an admin may need to allow custom connectors first.
