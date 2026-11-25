# Call log

After every Flypify call that spends credits or ad budget, the agent appends **one line** to `logs/flypify-calls.jsonl`. The file is git-ignored and stays on your machine. Over time it tells you (and the agent) what things really cost on your account, so quotes in `MASTER_CONTEXT.md` stay honest.

## Format

One JSON object per line:

```json
{"ts":"2026-01-15T14:02:11Z","capability":"statics.generate","store":"st_123","idempotency_key":"a1b2c3","credits_quoted":60,"credits_charged":60,"status":"done","job_id":"job_456","note":"6 statics, hero photo 2"}
```

| Field | Meaning |
|---|---|
| `ts` | UTC time of the call (ISO 8601) |
| `capability` | the agent capability called, e.g. `statics.generate`, `video.generate`, `listicles.generate`, `pages.build`, `campaigns.launch` |
| `store` | the store id it ran on, if any |
| `idempotency_key` | the key sent with the request (lets you match retries) |
| `credits_quoted` | the number from the quote the human said yes to |
| `credits_charged` | what Flypify reports as charged (`0` for a refunded or failed job; `null` until known) |
| `status` | `queued`, `done`, `failed`, `stuck`, `refunded` |
| `job_id` | job / campaign / listicle id returned |
| `note` | one short line of context |

For a campaign launch, log the ad budget from the launch preview in `note` (it is charged to the card on the ad account, not in credits).

## Rules for the agent

- Append, never rewrite earlier lines.
- Never write the API key or any token into the log.
- When a job finishes, append a second line with the final `credits_charged` and `status` instead of editing the first.
