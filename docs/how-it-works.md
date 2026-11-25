# How it works

Your agent talks to Flypify over one connection (MCP at `https://api.flypify.com/mcp/`, or the HTTP Agent API at `https://api.flypify.com/api/v1`), authenticated with your key. The skill in `skills/flypify/` tells it which agent capabilities to call, in what order, and where to stop and ask you.

## The launch loop

```mermaid
flowchart TD
    A[0. Connect<br/>account_status, flypify_capabilities, stores_list] --> B[1. Shortlist wide<br/>find_winners x3: Rising, LowRisk, Profit]
    B --> C[2. Verify the deal<br/>get_winner on the top 3: supplier, landed cost, margin, winning ads]
    C -->|no supplier or no winning ad| B
    C --> D[3. Decode why it wins<br/>search_ads, ads.formats, Brand Spy: one-screen brief]
    D --> E{4. Build the store}
    E -->|any paid plan| E1[push_to_shopify<br/>a draft product]
    E -->|Flypify store| E2[stores_create, storefront_update,<br/>pages_get / pages_update]
    E1 --> F[5. Pre-sell listicle<br/>for $30-$150, health-adjacent or new-category products]
    E2 --> F
    F --> G[6. Ads<br/>statics first, then 2-3 video hooks]
    G --> Q{{Quote shown<br/>you say yes?}}
    Q -->|yes| G2[generate, poll, score]
    Q -->|no| G
    G2 --> H[7. Campaign<br/>pixel check, create_campaign draft, launch preview]
    H --> L{{Exact charge shown<br/>you say launch?}}
    L -->|Scale plan| L1[launch_campaign]
    L -->|Starter / Growth| L2[you launch the draft in the Flypify app]
    L1 --> R[8. Report, then repeat weekly]
    L2 --> R
    R --> B
```

## Where the agent stops for you

| Moment | What you see | What happens without a yes |
|---|---|---|
| Static, video or listicle generation | the credit quote | nothing is generated |
| `pages.build` | "about 80 credits" | nothing is built |
| Publishing a product or listicle | the page or article | stays a draft |
| Campaign launch | the exact charge from the launch preview | stays a draft |
| Storefront, page or split-test edits | a `dry_run` diff | nothing is written |

Every change the agent makes is recorded as a revision (`revisions_list`) and can be put back (`revisions_restore`).

## Running several stores

Same loop, one winner per store, never the same product twice. The agent passes `store` on every call, adds up every quote across stores into one table for one yes, and keeps a ledger: store id, product, row, page, listicle, statics jobs, campaign. Up to 8 calls in flight per account; 4 stores side by side is the practical limit.
