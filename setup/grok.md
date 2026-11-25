# Grok (xAI API)

The xAI API can call remote MCP servers over Streamable HTTP. The grok.com chat app may not offer custom MCP servers; use the API, or the HTTP route in `generic-http.md`.

```python
import os
from openai import OpenAI  # xAI's API is OpenAI-compatible (Responses API)

client = OpenAI(api_key=os.environ["XAI_API_KEY"], base_url="https://api.x.ai/v1")
skill = open("skills/flypify/SKILL.md", encoding="utf-8").read()

resp = client.responses.create(
    model="grok-4",  # use a current Grok model name from docs.x.ai
    instructions=skill,
    tools=[{
        "type": "mcp",
        "server_label": "flypify",
        "server_url": "https://api.flypify.com/mcp/",
        "headers": {"Authorization": f"Bearer {os.environ['FLYPIFY_API_KEY']}"},
    }],
    input="Use Flypify: check my account status and list my stores.",
)
print(resp.output_text)
```

Notes:
- Check docs.x.ai (Remote MCP Tools) for the current field that carries the auth header in your SDK; some versions call it `authorization` or pass it through `extra_headers`.
- `require_approval` is not supported by xAI, so the agent will not pause for you. The skill's "quote, then ask" rule matters even more: keep spending turns human-in-the-loop by running one step per request.
- `allowed_tool_names` can limit Grok to read-only tools (for example `find_winners`, `get_winner`, `search_ads`, `search_brands`, `account_status`).
