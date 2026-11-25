# Stores: the 7-8 figure blueprint, through the API

Grounded in Flypify's teardown of 96 one-product DTC stores and 118 ad landers (ATELIER research, Nov 2026) and a first-screen study of 12 seven-figure product pages. What the strongest stores share is structure, not tricks: the page is one argument, every section answers one doubt, and proof shows up early and often. Flypify builds that structure with only true numbers.

Store-building capabilities (`stores.create`, `storefront.*`, `pages.*`) work on every paid plan, up to the plan's store count (Starter 5, Growth 35, Scale 100; past it `stores.create` answers `store_limit_reached`). Listing a product on a Whop store (`whop_store.add_product`) needs Scale; on Starter/Growth the human adds it in the app.

## 1. Build order (Flypify store, Scale)

| # | Call | Notes |
|---|---|---|
| 1 | `account_status`, `stores_list` | stores used vs cap (Starter 5, Growth 35, Scale 100) |
| 2 | `stores_create({"name", "niche"})` -> `stores_select({"store_id"})` | or pass `store` on every later call |
| 3 | `flypify_call("whop_store.add_product", {opportunity_id, price, image_urls?, text?})` | a real Whop product with checkout. `build_page: true` charges credits: leave it out unless the human approved the cost |
| 4 | `storefront_update({name, slug?, tagline?, support_email?, shipping_note?, returns_note?, hero_headline?, hero_subhead?, announcement?, dry_run: true})` | show the diff, then send without `dry_run` |
| 5 | `storefront_brand({"auto": true})` or `{palette, fonts}` | palettes: `classic` `blush` `sage` `navy` `bright` `earth` `noir` `ocean` `citrus` `lavender`; fonts: `classic` `editorial` `luxe` `modern` `friendly` |
| 6 | `pages_build(row_id)` (about 80 credits, ask first) or `pages_get(row_id)` then `pages_update` | writes copy for every section |
| 7 | `pages_update(row_id, {version, sections, dry_run: true})` | every section once, in the order you want it drawn |
| 8 | `pages_bundles(row_id, {"prices": {"1": .., "2": .., "3": ..}})` | the quantity ladder |
| 9 | `pages_refresh_reviews(row_id)` | real AliExpress buyer reviews (3 a day per page) |
| 10 | run the critic (section 5), fix, then `store_products_publish` only on a yes | |
| 11 | `storefront_domain_connect({"hostname": "shop.brand.com"})` -> add the DNS record -> `storefront_domain_check` | optional |

`row_id` is the store product row (`whop_store.products`, `storefront.get`, `store_products.list`). Store templates (Live Demo, Second Opinion, Porch Light, Field Apothecary and others) are chosen in the Flypify app; the agent edits sections inside whatever template the store uses.

## 2. Section order

Product page, full (problem-solving products, $30+, cold traffic). Flypify section kind in brackets.

| # | Section | Kind | What it must do |
|---|---|---|---|
| 1 | Announcement bar | `announcement` | one true line (max 60): a guarantee or why it is worth having. Never a fake deadline |
| 2 | Gallery + buy box | `gallery`, `hero`, `bundles` | first phone screen: outcome H1, rating line with source, price, bundle ladder, buy button |
| 3 | Trust row | `trust` | 3-4 badges: `lock` secure checkout, `shield` buyer protection, `return` (only with a returns policy) |
| 4 | Proof right under the hero | `proof`, `tiktok` | the real TikTok Shop stats and the winning TikToks |
| 5 | Problem | `problem` | one scene in the buyer's words, the not-your-fault cause, the fixes that failed |
| 6 | Mechanism / features | `features`, `use_cases` | why it works, one analogy; jobs it does |
| 7 | How to use | `how_it_works` | exactly 3 steps; step 1 is choosing a bundle |
| 8 | Reviews | `reviews` | stored buyer reviews, labelled by source |
| 9 | Us vs the old way | `comparison` | against the generic CATEGORY, never a named brand |
| 10 | What to expect | `timeline` | 3-4 steps of usage facts ("Week 1"), no promised results |
| 11 | Specs or ingredients | `specs`, `ingredients` | facts the merchant typed |
| 12 | Fit check | `fit_check` | who it is for and who it is not for (both sides) |
| 13 | Guarantee | `guarantee` | real days from the store's policy, in the last 4 sections |
| 14 | FAQ | `faq` | 5-8 mined objections incl. refund and shipping |
| 15 | Brand story | `story` | why we picked it, "we" voice, no invented history |

Lean page (impulse product under $30 sold by a demo ad): announcement -> gallery+hero+bundles -> trust -> tiktok -> problem -> reviews -> faq -> guarantee.

Evidence on position (median, product pages of 96 stores, 0 = top): buy box 0.21, problem 0.52, benefits 0.55, mechanism 0.56, comparison 0.70, guarantee 0.79, reviews 0.81, FAQ 0.87.

## 3. Copy formulas and field limits

| Field | Limit | Formula |
|---|---|---|
| `hero.headline` | 70 chars, 5-12 words | the buyer's outcome, not the product name: "Fall asleep in minutes, not hours". Shares under half its words with the title |
| `hero.bullets` | exactly 3, 48 chars each | each starts with an outcome or verb and carries a fact noun, unit or a removed pain |
| `eyebrow` / `dek` | 40 / 140 | optional label over and line under any section heading |
| `heading` (any section) | 60 | a claim or a buyer question, never a label. Banned: "Features", "Benefits", "Why choose us", "How it works", "Testimonials", "FAQ", "Our story" |
| `problem.pain` / `.alternatives` / `.mechanism` | 140 / 120 / 200 | pain in everyday words; alternatives as a category ("sprays and plug-ins"); mechanism in 1-2 sentences from product facts |
| `how_it_works.steps` | 3 x (40 title, 90 line) | choose bundle -> use -> result-free outcome |
| `timeline.steps` | 3-4 x (24 `when`, 90 line) | "Day 1", "Week 2": what the buyer does and notices, never a promised result |
| `faq.items` | q 90, a 300 | objections from 1-3 star reviews first |
| `guarantee` | title 40, lines 120 | days and conditions as the policy states them |
| `story.body` | 600 | "we" voice, no founder name, numbers or dates |
| `comparison.rows` | label 40, `us`/`others` booleans | 4-6 rows the buyer actually weighs; add `us_points`/`others_points` (2-5 each) for a two-column story |

Headings alone should carry the argument top to bottom: problem -> mechanism -> proof -> offer. If a skimmer reads only the headings they should want to buy.

## 4. Image direction, trust stack, offer

**Gallery order (the gallery is an argument):** 1 clean packshot -> 2 the product in use by the buyer persona -> 3 an infographic with 3 callouts -> 4 mechanism or detail close-up -> 5 the comparison or "what's in the box" -> 6 lifestyle result. Pass the best photo first in `store_products_update({"images": [...]})`. Regenerate a weak slot with `pages_regenerate_image(row_id, slot, {"note": "..."})` (credits; ask first), with a note that names the persona, the setting and the light ("hands of a woman in her 40s, kitchen counter, morning window light").

**Trust stack (in this order):** rating line with its source -> trust badges under the buy button -> the real TikToks -> reviews -> guarantee line at the buy box and a guarantee section near the end -> FAQ answering refund and shipping.

**Offer:** a 3-step quantity ladder where the per-unit price falls (`pages_bundles`). Middle tier pre-selected. Strike-through only from real maths (units x single price). "Most popular" only with order data, otherwise "Recommended". Free shipping only if every order ships free. No countdown, stock counter or "sold out N times" unless a real record backs it.

**One angle, ad to page:** the ad's hook, the listicle headline and the page H1 make the same promise. Rotate angles with new ads and split tests (`create_split_test` on `title`, `image`, `page` or `store_hero`), not by rewriting the page.

## 5. Pre-publish critic: 20 checks

Run every check, list pass/fail, fix the fails, then ask to publish. Render checks: open the store at 375x812 and 1280x800.

| # | Check |
|---|---|
| 1 | First phone screen (375x812) shows the outcome H1, the rating line, a price and a buy button without scrolling |
| 2 | H1 is an outcome, 5-12 words, max 70 chars, not the product title |
| 3 | The persona (who it is for) appears in the H1 or subhead; the subhead names the product category |
| 4 | Exactly 3 hero bullets, each under 48 chars, each with a concrete fact or removed pain |
| 5 | A proof section within the first two sections after the first screen; no run of more than 2 sections without proof |
| 6 | No run of more than 2 content sections without a way to buy; sticky bar on; last section is a buy box or final CTA |
| 7 | Problem section: one scene, the hidden cause, the failed fixes as a category |
| 8 | Mechanism explained with one analogy; how-to in 3 steps |
| 9 | Comparison is against the generic alternative, never a named brand |
| 10 | No heading is a bare label; at least 60% of headings are claims or buyer questions |
| 11 | Every number on the page comes from a record (TikTok Shop stats, review set, real prices). No invented %, counts or "customers" |
| 12 | Every review, quote and photo is real and labelled by source; no first-person quote that is not a stored review |
| 13 | No fake urgency: no countdown, "only N left", "selling fast" without a real offer or stock record |
| 14 | Strike-through prices are real maths; "Most popular" only with order data |
| 15 | Every "free" is true for every order; shipping text matches the store's shipping note |
| 16 | Guarantee days match the policy, shown at the buy box and in a section in the last four |
| 17 | FAQ has 5-8 items, sits in the last 40% of the page, answers refund, shipping and the top review objections |
| 18 | No health claims (cure, treat, heal, prevent, disease names, "clinically proven" without a source); no experts or press without a real record |
| 19 | Ad-landing pages have no exits: no store nav, related products or newsletter; footer keeps policies and contact |
| 20 | 375px: no horizontal scroll, no image wider than its box, tap targets 44px or more, FAQ opens |

## 6. Editing safely

- `pages_get(row_id)` returns the page and its `version`; send that `version` back in `pages_update` with every section once.
- To leave edits for the owner to approve, read `pages_get(row_id, {"draft": 1})`, send `draft: true` and the `draft_rev` it returned.
- A figure you type into a merchant section (`specs`, `ingredients`, `problem.stat`) goes only into the draft, for the owner to check.
- Section colour: `style: {"bg": "page" | "soft" | "accent" | "dark" | "#rrggbb"}` (not on announcement, gallery, hero). Alternate `page` and `soft`, one `dark` band for the comparison or final CTA.
- Owner-only (403 to agents): `store_reviews` content, the founder section, photo attestation.
- Every change is in `revisions_list`; `revisions_restore(rev_id)` undoes one.
