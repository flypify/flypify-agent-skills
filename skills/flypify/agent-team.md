# Agent team mode

Flypify can run as **one agent** (the default: one agent follows `SKILL.md` end to end) or as an **agent team**: a lead agent plus ten specialists, each owning one part of Flypify's capabilities and data. Same key, same money rules, more work in parallel and a narrower context per agent.

## Ask once, on first connection

The first time Flypify is connected in a workspace, before any other work, ask the human:

> How do you want to run Flypify?
> **1. Single agent.** One agent runs the whole launch loop. Simplest; best for one store at a time.
> **2. Agent team.** A lead agent plus 10 specialists (Winners Research, Brand Spy, Supplier Sourcing, Store Builder, Listicles, Static Ad Studio, Video Ad Studio, Meta Campaigns, Split Tests, Store Insights). Best for several stores or a steady weekly cadence.

Write the answer to `MASTER_CONTEXT.md` (`Mode:` under Account) and never ask again unless the human asks to switch.

- **Single agent:** carry on with `SKILL.md`.
- **Agent team:** install the team, then act as the lead (below).
  - Claude Code, Codex, Cursor, or any agent with a shell in this repo: run `./scripts/team.sh` (PowerShell: `scripts\team.ps1`). It copies every specialist from `team/` into `.claude/agents/` (Claude Code subagents) and into `.claude/skills/` and `.cursor/skills/` (as skills), and records the mode so later syncs keep them. Tell the human to restart the agent once so the new agents load.
  - Chat apps (ChatGPT, Grok, Claude.ai, Perplexity, Muse): follow `setup/agent-team.md`. Each specialist becomes its own project, GPT or agent with that file as its instructions.
  - To go back to one agent: `./scripts/team.sh --remove`.

## The roster

| Agent | Owns | Main capabilities | Hands off to |
|---|---|---|---|
| `flypify-winners-research` | Daily picks, TikTok Shop sales, trend check, sales evidence | `products.discover` / `find_winners`, `products.daily`, `products.trends`, `products.evidence`, `get_winner` | Supplier Sourcing, Brand Spy |
| `flypify-brand-spy` | Brand search, winning ad finder, hook spotter, format tags | `brands.search`, `brands.get`, `ads.search`, `ads.reveal`, `ads.formats`, `products.reveal_video` | Store Builder, Listicles, Static and Video Ad Studio |
| `flypify-supplier-sourcing` | Supplier match, AliExpress search, link verifier, margin math | `products.get`, `products.resolve_supplier_url`, `suppliers.*`, `products.upsells` | Store Builder |
| `flypify-store-builder` | Store create, theme picker, product pages, domain connect | `stores.*`, `themes.list`, `store_products.*`, `storefront.*`, `pages.*`, `domains.*`, `whop_store.*` | Listicles, Ad Studios, Split Tests |
| `flypify-listicles` | Angle ideas, advertorial draft, image swap, one-tap publish | `listicles.*` | Meta Campaigns |
| `flypify-static-ad-studio` | Concept brief, product hero shot, price quote, render batch | `statics.quote`, `statics.generate`, `statics.get` | Meta Campaigns |
| `flypify-video-ad-studio` | Format picker, hook and script, clip quote, render check | `ads.formats`, `video.quote`, `video.generate`, `video.get`, `ads.create_creative` | Meta Campaigns |
| `flypify-meta-campaigns` | Pixel check, audience reach, launch preview, launch to Meta | `campaigns.*`, `ads.copy` | Split Tests, Store Insights |
| `flypify-split-tests` | Variant builder, offer tests, results reader, winner picker | `split_tests.*` | Store Insights |
| `flypify-store-insights` | Sales reader, traffic check, page revisions, webhook alerts | `stores.insights`, `stores.sales`, `campaigns.list/get`, `revisions.*`, `webhooks.*` | Winners Research (next cycle) |

Each specialist file in `team/` says exactly which capabilities it may call and which it must leave to another agent.

## How the lead runs the team

The lead is the agent the human talks to. It does Step 0 of `SKILL.md` (account, capabilities, stores), owns `MASTER_CONTEXT.md`, and is the only agent that asks the human for a yes.

1. **Plan the cycle.** From the human's goal, write the jobs as a short list: which specialist, which store, what input, what output.
2. **Run independent jobs in parallel.** Winners Research and Brand Spy can run together; the two Ad Studios can run together once the store and brief exist. Keep at most 8 Flypify calls in flight across the whole team (`429 too_many_in_flight` otherwise), so at most 4 specialists working at once.
3. **Pass handoffs, not transcripts.** Every specialist ends with a `HANDOFF` block (format below). The lead gives the next specialist only that block plus the store id and the brief.
4. **Collect every quote into one table.** Specialists never spend: they quote and stop. The lead shows the human one table (store, item, credits or ad spend) and asks once. After the yes, it sends each specialist its approved line with the `expected_credits` and a fresh idempotency key.
5. **Keep the ledger.** After each handoff, update the Stores table and Changelog in `MASTER_CONTEXT.md`.

### Handoff block (every specialist ends its turn with one)

```text
HANDOFF
from: flypify-<agent>
store: <store id or "none">
done: <one line: what was produced>
ids: <opp_id / row_id / listicle_id / job ids / campaign_id ...>
facts: <the numbers the next agent needs, with their source field>
next: flypify-<agent> -> <what it should do>
needs_yes: none | <item, exact credits or spend, quote token if any>
risks: <anything unverified, blocked or refused, with the error code>
```

### Team rules (on top of `SKILL.md` section 2)

1. **One owner per capability.** A specialist calls only the capabilities in its file. If it needs something else, it says so in `next:`.
2. **Specialists never ask the human and never spend.** Anything with a quote, a card charge or a go-live goes into `needs_yes` and the specialist stops. Only the lead asks, with the number.
3. **One product per store, one store per stream.** Pass `store` explicitly on every call; never switch the current store mid-cycle without the lead.
4. **Facts travel with their source.** Revenue, saturation, landed cost and forecast bands are copied from Flypify fields, never rounded into claims. Anything not from a Flypify record is tagged `[estimate]`.
5. **The whole team shares one daily budget** (reveals, API calls, per-capability caps). Winners Research owns reveals; the lead tells it how many it may spend.
6. **Undo exists.** Any agent that writes to a store says so in `done:`; the lead can undo with `revisions.restore`.
