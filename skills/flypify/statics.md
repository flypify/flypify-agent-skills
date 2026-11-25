# Statics: briefing scroll-stopping image ads

Grounded in 1,119 tagged winning static ads across 12 niches (accessories, beauty, fashion, food, health, home, jewellery, kids, pets, sports, tech, supplements) and in what the Flypify Ad Studio planner actually does with your inputs.

**What the winners have in common (share of the 1,119):**

| Finding | Share |
|---|---|
| The product is the hero (over a third of the frame, or clearly the subject) | 83% |
| Headline of 4 words or fewer, or no words at all | 69% |
| Designed brand graphic (not a phone-screenshot look) | 76% |
| No person in the image | 63% |
| Solid-colour or indoor lifestyle background | 83% |
| Leads with a benefit (26%), an offer (10%), a problem (6%); no hook text at all (39%) | |
| Shows an offer (% off, price, free gift) | 22% |
| Shows a review or rating | 9% |

So: a beautiful, large, well-lit product, one short line, one idea. Scroll-stopping comes from the image (scale, colour, motion frozen in air, an unexpected setting), not from paragraphs of text.

## 1. The call

```
statics_quote(count)                      -> show the total, wait for yes
statics_generate(
  product_url,        # the product page, https, no port
  count,              # 1-10 square 1:1 images
  idempotency_key,    # NEW random string per set
  expected_credits,   # the quoted total (required)
  image_url,          # the best product photo, https on *.whop.com, *.alicdn.com or *.aliexpress-media.com
  title,              # buyer-facing name, max 200
  description,        # what it is and does, max 2000
  price,              # e.g. "$29.99", max 40
  selling_points      # up to 10 strings, each max 300, 2000 in all
)
statics_get(job_id)                       -> every 15-30 s, up to ~30 min
```

Always pass `image_url`, `title` and `selling_points`. Supplier pages are often bot-walled, and the plan is then written only from what you pass (`no_product_facts` if there is no title).

## 2. Picking the hero image

Pick from `get_winner`'s photos or the store product's `images`:

1. The whole product, sharp, front or three-quarter, no cut-off edges.
2. Clean or plain background (the Ad Studio builds the scene around it).
3. Packaging text readable: the Ad Studio keeps printed label text exact and never redraws it.
4. No watermark, collage, size chart or supplier text banner.
5. If the only good photos are lifestyle shots, use the one where the product is largest.

## 3. Writing selling points that become strong headlines

The planner writes headlines of at most 8 words from your facts and checks every claim against them. Your selling points are the raw material, so write them as the buyer would say them.

| Do | Don't |
|---|---|
| One idea per line, 3-10 words | a paragraph of features |
| Outcome first: "Dull skin rolls right off" | "Contains kojic acid 2%" (a spec, not a reason) |
| The old way it replaces: "No more sticky lint rollers" | a competitor's brand name |
| A sensory or visual fact: "Foams on contact" | adjectives: "premium", "amazing", "revolutionary" |
| A real offer on its own line, 2-6 words: "20% off this week" | an offer you are not actually running |
| The set or pack if you sell one: "Comes as a 3-pack" | invented variants or colours |
| Who it is for: "For dogs that hate baths" | numbers you cannot back ("97% saw results") |

Give 5-8 points for a set of 6. Thin facts are the cause of `plan_too_thin`.

How your inputs unlock layouts:

| You pass | Unlocks |
|---|---|
| a real offer as its own selling-point line (2-6 words, max 48 chars, no "!" or "?", e.g. "20% off this week", "Free shipping on every order") | the offer-promo layout |
| a set, pack or bundle named in a selling point or the page | the bundle line-up layout |
| a product with stored buyer reviews | the two quote layouts (claim card, notes screenshot), signed "verified buyer", word for word |
| a pain or old-way line | pain callout, problem question, us-vs-them, objection answered |

You cannot pick a layout directly: the planner mixes layouts by what wins in the product's niche and by what your facts support. You steer it through the facts.

## 4. Ten proven static archetypes

| # | Archetype | Share of winners | Looks like | Use when | Feed it |
|---|---|---|---|---|---|
| 1 | Product hero | 37% | the product large, lit like a brand shoot, a 2-6 word benefit line | always: the backbone of every set | the best photo, 2-3 outcome lines |
| 2 | Offer promo | 12% | the deal dominates, product beside it | a real sale or bundle deal is running | the offer on its own line |
| 3 | No-text / plain UGC hero | 11% | the product in a real-looking scene, little or no text | visual products: decor, jewellery, gadgets that explain themselves | a striking photo, a setting line ("on a marble bathroom shelf") |
| 4 | In use | 8% | a hand or person using it, short overlay | the use is the hook (tools, pet, beauty) | who uses it and where |
| 5 | Feature callouts | 7% | product centred, 3-4 arrows to short labels | gadgets and multi-benefit products | 3-4 three-word features |
| 6 | Claim card | 5% | one bold claim or one verbatim customer line + product | products with strong reviews | stored reviews; one sharp claim |
| 7 | Bundle line-up | 5% | several units lined up | multi-packs, refills, sets | "Comes as a 3-pack" |
| 8 | Us vs them | 2.5% | two columns, ours vs the old way, ticks and crosses | switching products (old way is obvious) | 3 lines naming the old way as a category |
| 9 | Before / after | 2% | one frame split in two states | visible change (cleaning, organising, grooming) | the before state and the after state in words; never a fake body result |
| 10 | Problem question / pain callout | 1-2% | one big question or pain over a candid photo | problem-aware audiences | the pain in the buyer's words |

Native phone-look layouts (notes screenshot, objection answered, how it works) are rare among winners (under 1% each) but useful as pattern breaks: one per set at most.

## 5. How many to make

| Goal | Count |
|---|---|
| First look at a new product | 3 |
| Angle test for a launch (the default) | 6: product hero x2, one per other angle your facts unlock |
| Full test across angles | 10 (needs 8+ distinct selling points, else `plan_too_thin`) |
| Second round after a winner | 3-6 built from the winning image's line |

Statics are capped at 10 sets a day per account; one set runs at a time (`batch_running`).

## 6. Judge every image before you show it

Score each 0-2, keep 8+ out of 10:

| Check | 2 = |
|---|---|
| Thumb-stop | at phone size, the eye lands on the product in under a second |
| Product truth | the product matches the real one; label text exact |
| One message | one headline, readable at a glance, 8 words or fewer |
| Specific | the line could not be pasted on a rival's product |
| Honest | no invented rating, count, %, expert or deadline |

Then:
- A generic headline ("Elevate your routine"): rewrite the selling points sharper and run a new set with a new key.
- Product looks wrong: change `image_url` to a cleaner photo.
- All six look alike: add selling points that unlock other layouts (an offer line, the old way, a pack).
- Keep the best 3-4. Launch them as separate ads with one hook each; the platform picks.

## 7. After the test

The winning static's line becomes: the video hook (`video_generate` prompt), the page H1 test (`create_split_test` on `title` or `store_hero`), and the listicle headline. One angle, ad to page.
