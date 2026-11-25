# Flypify Prompt Pack: 25 prompts

Copy, fill the {braces}, paste into any agent with Flypify connected (see `setup/` at the repo root). Every prompt assumes the agent follows `skills/flypify/SKILL.md`: it quotes before any spend and asks before anything goes live.

## Find products

**1. Winners in a niche**
> Use Flypify. In {niche}, pull winners sorted Rising, LowRisk and Profit (10 each). Show me the 5 that appear on two lists or score best on revenue, saturation under 40%, 30-180 days running and a forecast low line above zero. One line each on why. Don't reveal any yet.

**2. Deep check on 3 finalists**
> Use Flypify. Reveal {opp_id_1}, {opp_id_2}, {opp_id_3}. For each: supplier link, landed cost, suggested price at 3x, margin, forecast band, and the winning TikToks. Drop any without both a verified supplier and a winning ad. Recommend one.

**3. Judge my product idea**
> Use Flypify. Here is a product link: {url}. Is it a Flypify winner? If yes, give me revenue, saturation, days running, trend and supplier. If not, find the 3 most similar winners and tell me which to sell instead.

**4. Weekly winner refresh**
> Use Flypify. It's my weekly refresh for {niche}. Pull Rising winners, compare with last week's list I paste below, and tell me what is new, what is fading and whether anything beats the product I'm running ({product}). {paste last week's list}

**5. Trend scout**
> Use Flypify. Show rising trend keywords in {niche}, then search winners for the top 3 keywords. Give me the 3 products where a trend and a proven seller line up.

**6. Bundle builder**
> Use Flypify. For {product title}, suggest upsells and bundle add-ons, then propose a 1 / 2 / 3 quantity ladder with per-unit prices that keep at least 50% margin.

## Spy on competitors

**7. Clone a competitor's angle (not their assets)**
> Use Flypify Brand Spy. Find the top 3 rising brands in {niche} over 30 days. For the strongest, pull its live ads and landing page and fill the brand card from brand-spy.md. Then give me the angle they are NOT using and a plan to own it.

**8. Longest-running ads in a niche**
> Use Flypify. Show the 10 longest-running ads in {niche}. Group them by hook style, tell me which 3 formats dominate, and write me one hook in each format for {my product}.

**9. Reverse-engineer one brand**
> Use Flypify. Look up the brand {brand name}. What do they sell, at what price ladder, what do they promise above the fold, which ad formats do they scale, and what doubt does their page leave unanswered?

## Build stores

**10. Full store from one winner (Scale)**
> Use Flypify. Build a full store for winner {opp_id}: create the store "{store name}" in {niche}, list the product at {price}, set the storefront and brand automatically, then build the product page in the 15-section order from stores.md. Quote anything that costs credits first. Run the 20-point critic and show me the fails before publishing.

**11. Shopify draft (any plan)**
> Use Flypify. Push winner {opp_id} to my Shopify as a draft with a buyer-facing title (outcome + who it's for) and price {price}. Then give me the product description and the 15-section page plan from stores.md to paste in.

**12. Rewrite my page to the 7-figure standard**
> Use Flypify. Read the page for row {row_id}. Score it against the 20-point critic in stores.md, then propose fixes as a dry run: new H1, 3 bullets, headings as claims, problem section, comparison against the old way, FAQ from real review objections. Show me the diff before writing.

**13. Pick a look**
> Use Flypify. For store {store_id}, recommend a palette and font pair from the Flypify lists that fits {niche} and a ${price} product, explain why in one line, and apply it as a dry run first.

**14. Five stores in parallel**
> Use Flypify. Check how many stores my plan has left. Pick {5} different store-ready winners in {niches}, one per store, never the same product twice. Give me one table of every credit cost across all five, wait for my yes, then build each store with its own store id and keep a ledger (store, product, row, page, listicle, statics jobs).

**15. Connect my domain**
> Use Flypify. Put store {store_id} on shop.{mydomain}.com. Tell me the exact DNS record to add, then check it until it's live.

## Listicles

**16. Write a listicle**
> Use Flypify. Suggest article ideas for row {row_id}, pick the best switching angle with 7 reasons, quote it, and after my yes write it. Then tighten it with listicles.md: headings as claims, one real review quote, a cost comparison, a fit check. Show it before publishing.

**17. Three angles, three articles**
> Use Flypify. For row {row_id}, plan three listicles: switching, last-attempt and gift (or signs). Give me titles, angles and reason counts, total quote for all three, then write them after my yes.

**18. Advertorial for a pricier product**
> Use Flypify. Row {row_id} sells at ${price}. Write a story-first article using the "How {audience} are {outcome} without {disliked fix}" headline: problem and failed fixes first, product no earlier than reason 3, guarantee last.

## Ads

**19. Six scroll-stopping statics**
> Use Flypify. Make 6 static ads for {product}. Pick the best product photo, write 6-8 selling points as the buyer would say them (outcome first, the old way it replaces, one real offer line if I'm running one: {offer or none}), quote, wait for my yes, generate, and score every image with the statics.md rubric before showing me the keepers.

**20. Round two from the winning static**
> Use Flypify. My best static says "{winning headline}". Make 3 more that keep its promise but change the scene and layout, then turn the line into a page H1 split test and a 6-second video hook.

**21. Video hooks**
> Use Flypify. Write three 6-second hook clips for {product}, each one scene and one action with the real product photo as reference, 9:16. Quote the cheapest model for all three, wait for my yes, generate and send me the links.

## Launch and optimise

**22. Launch a test campaign**
> Use Flypify. Check my ad account setup and pixel for {store url}. Draft a test campaign for {product} with {statics or video}, ${daily budget}/day, {countries}. Show me the launch preview with the exact charge. Do not launch until I say "launch".

**23. Split test the hero**
> Use Flypify. On row {row_id}, read the split-test history first, then start a test on the store hero with 2 challenger headlines built from my best ad angles. Dry run first and send me the preview links.

**24. Weekly review**
> Use Flypify. For store {store_id}: campaigns and results this week, split tests and who is winning, what my agent changed (revisions). Recommend 3 next moves in order of expected impact, honest about what is just a guess.

**25. Undo**
> Use Flypify. Show me every change the agent made to store {store_id} in the last 7 days and restore {the one I name}.
