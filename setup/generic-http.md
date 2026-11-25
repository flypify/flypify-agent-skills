# Any agent or script: HTTP Agent API (and generic MCP)

## Generic MCP client (Muse, Windsurf, n8n, custom agents)

| Setting | Value |
|---|---|
| Transport | Streamable HTTP |
| URL | `https://api.flypify.com/mcp/` (trailing slash; `/mcp` redirects) |
| Auth | `Authorization: Bearer flypify_live_...` (or `X-Flypify-Key: flypify_live_...`), or OAuth sign-in by URL if the client supports it |

Load `skills/flypify/SKILL.md` as the agent's system prompt or instructions.

## HTTP (no MCP needed)

Base URL `https://api.flypify.com/api/v1`. Same key, same capabilities as MCP.

| Need | Request |
|---|---|
| List capabilities | `GET /api/v1` |
| Input shapes | `GET /api/v1/openapi.json` (import this into GPT Actions, Postman, any tool-calling SDK) |
| Find winners | `GET /api/v1/products/discover?category=Pets&sort=Rising&limit=25` |
| One winner, full detail | `GET /api/v1/products/{opp_id}` |
| Winning TikToks | `POST /api/v1/products/{opp_id}/winning-ad` |
| Ads in a niche | `GET /api/v1/ads/search?niche=Pets&sort=longest` |
| Brands | `GET /api/v1/brands?niche=Pets&sort=rising&range=30d` |
| Quote statics | `POST /api/v1/statics/quote` `{"count": 6}` |
| Make statics | `POST /api/v1/statics/generate` (see `skills/flypify/statics.md`) |
| Poll statics | `GET /api/v1/statics/{job_id}` |

```bash
export FLYPIFY_API_KEY="flypify_live_..."

curl -s https://api.flypify.com/api/v1/stores \
  -H "Authorization: Bearer $FLYPIFY_API_KEY"

curl -s "https://api.flypify.com/api/v1/products/discover?category=Pets&sort=Rising&limit=10" \
  -H "Authorization: Bearer $FLYPIFY_API_KEY"

curl -s -X POST https://api.flypify.com/api/v1/statics/quote \
  -H "Authorization: Bearer $FLYPIFY_API_KEY" -H "Content-Type: application/json" \
  -d '{"count": 6}'
```

Errors come back as `{"error": {"code": "...", "message": "..."}}`; the codes and what to do are in `skills/flypify/SKILL.md` section 4. HTTP and MCP share the same plan limits and reveal budget (2,000 calls/day on Starter/Growth, 20,000 on Scale, 8 at once).
