# Listicles and pre-sell articles

Cold traffic that meets a product page cold often bounces. The strongest DTC stores send it through a pre-sell article first: each section removes one doubt, nothing asks for money before the reader understands the product, and a skimmer gets the whole argument from the headings. Grounded in 38 listicle landers and 13 advertorials from Flypify's teardown research (median listicle: 885 words, 3 CTAs, offer box near the end, reviews before it).

Listicle capabilities work on every paid plan. `listicles.suggest` is capped at 30 calls a day per key; generating text and photos costs credits, so quote first.

## 1. Should this product get one?

| Signal | Send ads to |
|---|---|
| Under $30, the ad demonstrates the product | the product page; no article |
| $30-$80, solves a problem or has several benefits | a listicle (default) |
| Over $80, health-adjacent, or a new category | an advertorial-style listicle (story first, product late); a second listicle as another angle |
| Gift-able, in season | a gift listicle |

## 2. The calls

| # | Call | Notes |
|---|---|---|
| 1 | `listicles_suggest(row_id)` | free ideas: title, angle, reason count |
| 2 | pick one, or write your own `pick: {title, angle, reasons}` | `reasons` is 5, 7 or 11; the number in the title must equal it; title max 90 chars, angle max 140 |
| 3 | `listicles_quote({row_id, pick})` | 30 credits for the text plus the per-image price for each photo. Show it, wait for yes |
| 4 | `listicles_generate({row_id, pick, idempotency_key})` | new random key per article |
| 5 | poll `listicles_get(listicle_id)` | until the reasons and photos are in |
| 6 | `listicles_edit(listicle_id, {version, ...})` | tighten headings, reorder reasons, add extras (below) |
| 7 | `listicles_regenerate_image(listicle_id, reason_id)` without `confirm` | that is the price; call again with `params: {"confirm": 1}` only after a yes |
| 8 | critic (section 6), then `listicles_publish(listicle_id)` on a yes | `listicles_unpublish` takes it back to draft |

Ad link: each ad points to the article whose headline continues the ad's hook.

## 3. Headline formulas (pick the variant from the brief)

| Variant | Formula | Example |
|---|---|---|
| Switching (default) | {n} reasons why {audience} are {switching} from {old way} to {category} | 5 reasons why cyclists are trading degreaser sprays for a chain wax dip |
| Choose over | {n} reasons {audience} choose {product} over {old way} | 7 reasons home baristas choose a hand grinder over pre-ground coffee |
| Last attempt | {n} reasons your last attempt to {goal} didn't stick | 7 reasons your last attempt to stop snacking at night didn't stick |
| Myths | {n} things {audience} get told about {problem} that don't hold up | 5 things new cat owners get told about litter smell that don't hold up |
| Signs | {n} signs {hidden problem} is behind your {symptom}, and what you can do about it | 5 signs your pillow is behind your stiff neck, and what you can do about it |
| Gift | {n} reasons {category} is the gift {recipient} will actually use this {season} | 7 reasons a heated eye mask is the gift night-shift workers will actually use this Christmas |
| Advertorial | How {audience} are {getting outcome} without {disliked fix} | How older gardeners are keeping slugs off the lettuce without pellets or beer traps |
| Reversal | {sensible fix} was supposed to {solve it}. For {audience}, it made {problem} worse. | Switching to a standing desk was supposed to fix the back pain. For many office workers, it moved it. |

Rules: name the audience; name the old way as a category, never a brand; no figure the article cannot back.

## 4. Structure (what to put in each reason)

For a 7-reason switching listicle:

| Reason | Job |
|---|---|
| 1 | the pain the reader already feels, in their words |
| 2-3 | why the usual fixes fall short (categories, not brands) |
| 4 | how this product works differently: one analogy |
| 5 | the proof: a real review quote (`pull_quote`, verbatim, with `review_id`) |
| 6 | the value: cost against the old way (`extras.cost`) |
| 7 | the risk reversal: the guarantee as the store's policy states it |

Then: reviews -> comparison -> offer -> FAQ (3-4 items) -> final call to buy. One exit: every button goes to the product's buy box.

Field limits: `intro` 700, reason `heading` 80, reason `body` 700, `closing` 500. Heading = a claim the reader can skim ("Sprays mask the smell, this removes it"), never "Reason 3".

`extras` you can add with `listicles_edit` (merged over what is stored; null clears):

| Extra | Use |
|---|---|
| `hero_caption` | one line under the hero image |
| `takeaways` | 3 bullet TL;DR at the top for skimmers |
| `verdict` | the one-line conclusion before the offer |
| `fit: {for, not_for}` | honest fit check: builds trust |
| `options: [{name, good_at, falls_short, suits?, ours?}]` | what people usually try, each with what it is good at AND where it falls short, ours included |
| `cost: {old_way, unit, unit_price, per_year, ours_per_year?, basis?}` | the cost maths against the old way |
| `sources: [{label, url (https), scope?}]` | citations a reader can follow, linked from reasons via `sources: [n]` |

## 5. Image direction (one image per reason)

| Reason type | Image |
|---|---|
| pain | the persona mid-problem, candid, phone-camera look, no product |
| failed fix | the old way, plain and a little tired |
| mechanism | close-up of the product doing its one thing |
| proof | the product in a real home, hands in frame |
| value | the product beside what it replaces |
| guarantee | clean packshot on a soft background |

Regenerate a weak photo with a note naming the persona, place and light. Never an AI-made "customer", "doctor" or before/after.

## 6. Article critic (before publish)

1. Title number equals the reason count (5, 7 or 11 at generate; 3-11 after edits).
2. Headings alone tell the story: pain -> failed fixes -> mechanism -> proof -> offer.
3. The product is named no earlier than reason 3 on an advertorial-style piece.
4. Every quote is verbatim from a stored review; no invented names, ratings or counts.
5. No countdown, stock counter, "doctor recommended" or press logo without a real record.
6. No health claims (cure, treat, prevent, disease names).
7. The byline is the brand, or a real person who agreed to it.
8. One exit: no store menu, other products or newsletter in the article.
9. The ad's hook and the article headline make the same promise.
10. Renders at 375px with no sideways scroll.
