# Agent team setup

Agent team mode gives you a lead agent plus ten specialists, each one owning a part of Flypify: Winners Research, Brand Spy, Supplier Sourcing, Store Builder, Listicles, Static Ad Studio, Video Ad Studio, Meta Campaigns, Split Tests and Store Insights. How the lead runs them, the roster and the handoff format: [`skills/flypify/agent-team.md`](../skills/flypify/agent-team.md). Each specialist's instructions: [`team/`](../team/).

Your agent asks "single agent or agent team?" the first time it connects. Pick team, then follow the section for your client.

## Claude Code

```bash
./scripts/team.sh        # PowerShell: scripts\team.ps1
```

Restart Claude Code. `/agents` lists ten subagents named `flypify-*`; the main session is the lead and hands work to them. Every subagent uses the same `flypify` MCP server and key. Back to one agent: `./scripts/team.sh --remove`.

## Codex and Cursor

Run the same script. It installs each specialist as a skill (`.claude/skills/flypify-*` and `.cursor/skills/flypify-*`). The lead agent reads `skills/flypify/agent-team.md` and works through one specialist skill at a time, or you open one session per specialist and paste its handoff into the next.

## Grok (xAI API)

Each specialist is one Grok agent: same Flypify MCP tool, its own instructions.

```python
import os, pathlib
from openai import OpenAI

client = OpenAI(api_key=os.environ["XAI_API_KEY"], base_url="https://api.x.ai/v1")
flypify = {
    "type": "mcp",
    "server_label": "flypify",
    "server_url": "https://api.flypify.com/mcp/",
    "headers": {"Authorization": f"Bearer {os.environ['FLYPIFY_API_KEY']}"},
}
core = pathlib.Path("skills/flypify/SKILL.md").read_text(encoding="utf-8")

def specialist(name: str, task: str) -> str:
    role = pathlib.Path(f"team/{name}.md").read_text(encoding="utf-8")
    r = client.responses.create(
        model="grok-4",  # a current Grok model name from docs.x.ai
        instructions=role + "\n\n---\n\n" + core,
        tools=[flypify],
        input=task,
    )
    return r.output_text  # ends with a HANDOFF block

shortlist = specialist("winners-research", "Find 5 winners in pet care for store 12 with 30 reveals and pick one.")
sourcing = specialist("supplier-sourcing", "Verify supplier and margin.\n\n" + shortlist.split("HANDOFF", 1)[-1])
```

xAI does not pause for approval, so keep spending steps (statics, video, listicles, page builds, campaign launches) as separate requests you run only after reading the specialist's `needs_yes` line.

## ChatGPT, Claude.ai, Perplexity, Muse

Make one project (or custom GPT, or Space) per specialist you use most, each connected to Flypify the way the client's guide in [`setup/`](.) describes:

1. Name it after the specialist, for example "Flypify Brand Spy".
2. Paste the specialist file from `team/` as its instructions, and attach `skills/flypify/SKILL.md` (and the companion file it names, such as `brand-spy.md` or `statics.md`) as knowledge.
3. Make one more project, "Flypify Lead", with `skills/flypify/agent-team.md` and `SKILL.md`.
4. Work in the lead. When it hands a job to a specialist, open that project, paste the job and the last `HANDOFF` block, and bring the specialist's `HANDOFF` back to the lead.

A good starting set if you don't want all ten: Winners Research, Brand Spy, Store Builder, Static Ad Studio and Meta Campaigns.

## Rules every client keeps

- Only the lead asks you for a yes. Specialists quote and stop.
- At most 8 Flypify calls in flight per account across the whole team.
- One product per store; every call names its `store`.
- Your key goes in the client's secret or connector settings, never into a chat.
