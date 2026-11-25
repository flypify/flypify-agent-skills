# Brand Spy: reverse-engineer a competitor

Goal: learn why a brand is scaling and turn that into your own store and ad plan, copying structure and angle, never their name, footage, photos or words.

## 1. What to pull

| # | Call | What you get |
|---|---|---|
| 1 | `search_brands(q?, niche?, limit)` or `flypify_call("brands.search", {...})` | brands running winning ads, their stores and ad counts |
| 2 | `flypify_call("brands.get", {"brand_key": ...})` | one brand: its store, products, live ads and a 30-day line |
| 3 | `search_ads(niche, sort="longest")` | the ads that have run longest in the niche (long-running = still profitable) |
| 4 | `flypify_call("ads.reveal", {"ad_key": ...})` | one ad's links: the ad, its landing page, the advertiser |
| 5 | `flypify_call("ads.formats", {"niche": ...})` | the hook styles the library classifies |
| 6 | `winner_from_url(url)` / `flypify_call("products.from_url", {"url": ...})` | is their product a Flypify winner? (revenue, saturation, supplier) |
| 7 | `flypify_call("products.similar", {"q": ...})` | winners close to their product, for a different angle |

`brands.search` filters: `sort` = `active` (most live ads), `rising`, `rising_pct`, `longest`, `video_share`, `traffic_growth`; `range` = `7d`, `14d`, `30d`; `shopify=1` for Shopify stores; `monthly_visits_min`. `search_ads` filters: `sort` = `longest` or `recent`; `sources` = `all`, `facebook`, `tiktok`.

Find the brands worth studying: `sort: "rising"` over `range: "30d"` in your niche, then the 3 with the most live ads.

## 2. What to write down (one card per brand)

| Field | Where from |
|---|---|
| Product and price ladder | `brands.get` products; their landing page |
| The one promise (hero H1) | the landing page from `ads.reveal` |
| The audience they name | ad copy, page H1/subhead |
| The old way they position against | comparison section |
| Ad formats they scale | `ads.formats` + their longest-running ads |
| Hooks of the 3 longest-running ads | first line / first 2 seconds of each |
| Landing type | product page, listicle or advertorial |
| Proof stack | reviews, UGC, guarantee, what they show above the fold |
| Offer | bundles, gifts, guarantee days |
| Gaps | a doubt their page does not answer; a buyer they ignore; review complaints |

## 3. Turn it into a plan

1. **Pick the angle they are not using.** Same product category, a different buyer or a different old way. Their gaps row is your H1.
2. **Source it.** `winner_from_url` on their product. If it is a Flypify winner with `store_ready: true`, `get_winner` gives the supplier and the winning TikToks. If not, `find_suppliers(title)` and `products.similar` for a verified alternative.
3. **Match the landing type.** They scale on a listicle: you need one too (`listicles.md`). On the product page alone: build the full page (`stores.md`).
4. **Match the format mix, not the creatives.** If their longest runners are product-hero statics and demo videos, brief 6 statics (`statics.md`) and 2-3 video hooks with your own photos and words.
5. **Beat the offer honestly.** A clearer bundle ladder, a real guarantee, answers to the doubts their reviews raise.
6. **Write the plan as a table:** angle, audience, H1, landing type, 6 static lines, 3 video hooks, offer, test order.

## 4. Rules

- Never use their brand name, logo, photos, footage, reviews or exact wording on your store or ads.
- Never claim to be them, to be "the original" or that theirs is a copy.
- Compare against the category ("cheap sprays"), never against them by name.
- Their numbers are theirs: never put their review count, sales or press on your page.
