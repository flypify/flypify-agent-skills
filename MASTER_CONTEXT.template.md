# Master context

Your workspace memory. `scripts/setup.sh` copies this template to `MASTER_CONTEXT.md`, which is git-ignored, so what you write here stays on your machine.

## How agents use this file

- **At the start of every session:** read it before calling Flypify. Use the defaults below instead of asking again.
- **When a field is empty:** ask the human once, then write the answer back here.
- **After meaningful work:** add a dated line to the [Changelog](#changelog) (what changed, why, ids).
- **Never** write the API key here. It lives in `.env`.

## Account

- **Mode:** _(single agent / agent team; asked once on first connection, see `skills/flypify/agent-team.md`)_
- **Plan:** _(Starter / Growth / Scale; read from `account_status` on first use)_
- **Stores allowed:** _(Starter 5, Growth 35, Scale 100)_
- **Shopify connected:** _(yes / no)_

## Defaults

- **Default niche:**
- **Target margin:** _(the skill's rule of thumb: sell at 3x landed cost or more; Flypify refuses a price under the 25% margin floor)_
- **Price range I sell in:**
- **Countries I ship to / advertise in:**
- **Default daily ad budget per test:**

## Stores

| Store id | Name | Niche | Product (opp_id) | Row id | Domain | Status |
|---|---|---|---|---|---|---|
| | | | | | | |

## Brand voice

- **Buyer (one named persona):**
- **Tone:**
- **Words to use:**
- **Words to avoid:**
- **Offer I'm running (or none):**

## Credit spend learnings

What things actually cost on this account, so quotes never surprise anyone. Fill from the quotes and from `logs/flypify-calls.jsonl`.

| Capability | Typical quote | Notes |
|---|---|---|
| `statics.generate` | | per set of N images |
| `video.generate` | | per model and seconds |
| `listicles.generate` | | |
| `pages.build` | about 80 credits (no quote endpoint) | say the number and ask |

## What worked / what didn't

- 

## Changelog

<!-- Newest first. One line each: YYYY-MM-DD: what changed (store / ids), why. -->
