# ScriptGrain MCP server

ScriptGrain makes ChatGPT, Claude and the rest better at being you. This
repository is the public setup guide for its remote MCP server: connect it
to Claude, ChatGPT, Cursor or any MCP client, and your assistant can build a
voice profile from your own writing, draft in that voice, and score any text
against it.

- **Endpoint:** `https://mcp.scriptgrain.com/mcp` (streamable HTTP, answered as plain JSON; legacy SSE at `https://mcp.scriptgrain.com/sse`)
- **Auth:** OAuth 2.0 (sign in with your ScriptGrain account on the consent page; used by claude.ai and ChatGPT connectors), or a ScriptGrain API key sent as `Authorization: Bearer sg_live_...`
- **Plans:** every plan, including Free. Drafting uses credits from your plan; scoring and reading are free.
- **Server version:** 1.20.0, 36 tools and 2 prompts; every tool has a title and read-only / destructive hints
- **Website:** https://scriptgrain.com · **Docs:** https://scriptgrain.com/docs/mcp.md · **REST API:** https://scriptgrain.com/docs/api.md

This repository is a guide: documentation and client configuration only. It
contains no ScriptGrain source code; the application and the MCP server are
private and hosted by ScriptGrain, so there is nothing to install or run.

## What ScriptGrain measures

A voice profile is built from writing you have already done: 45 attributes in
eight groups (lexical, syntax, tone and register, rhetoric, punctuation and
format, function words, content patterns, quirks and cadence). Every draft is
scored from 0 to 1 against the profile: on-voice drafts typically score 0.85
to 0.95, partial matches 0.5 to 0.8, and clearly off-voice text below 0.45.
Each attribute has its own page at https://scriptgrain.com/attributes.

## Connect

You need a ScriptGrain account (free): https://scriptgrain.com/auth?tab=signup&source=github_mcp

### claude.ai (web) and Claude Desktop

1. Settings, then Connectors, then **Add custom connector**.
2. Paste `https://mcp.scriptgrain.com/mcp`.
3. Sign in with your ScriptGrain email and password on the consent page. If you signed up with Google, open "Paste an API key instead" and paste a key from https://scriptgrain.com/settings?tab=api.

The connector mints its own API key, named after the client, in your
ScriptGrain account. Revoke it in Settings, API, and the access ends.

### Claude Code

With OAuth (Claude Code opens the sign-in when you run `/mcp`):

```bash
claude mcp add --transport http scriptgrain https://mcp.scriptgrain.com/mcp
```

With an API key:

```bash
claude mcp add scriptgrain https://mcp.scriptgrain.com/mcp \
  --transport http --header "Authorization: Bearer sg_live_<your-secret>"
```

Project-scoped config for a shared repository: [`config/claude-code.mcp.json`](config/claude-code.mcp.json) (OAuth, so no key is committed).

### ChatGPT

Where your ChatGPT plan offers connectors: Settings, then Connectors, then
**Add custom connector**, with the URL `https://mcp.scriptgrain.com/mcp`, and
sign in with your ScriptGrain account when the consent page opens. Where
connectors are not available on your plan, the free prompt builder at
https://scriptgrain.com/works-with/chatgpt writes a one-page system prompt
from your writing for Custom instructions instead.

### Cursor (and other editors with MCP settings)

Add a remote MCP server named `scriptgrain` with the URL
`https://mcp.scriptgrain.com/mcp` and complete the sign-in when the consent
page opens: [`config/cursor.mcp.json`](config/cursor.mcp.json). Where a
client cannot do OAuth, send the key as a header instead:
[`config/cursor.mcp.with-key.json`](config/cursor.mcp.with-key.json). Keep a
file that holds a key out of version control.

### Any other MCP client

Use `https://mcp.scriptgrain.com/mcp` with OAuth or the `Authorization:
Bearer` header. Every POST is answered as plain JSON, never as an event
stream, so clients and proxies that only handle request and response work
too. Send the `Mcp-Session-Id` header from the initialize response on every
later call.

## Tools

36 tools, listed from the server's own registrations (server 1.20.0). The tools that delete or overwrite (`delete_memory`, `forget_piece`, `edit_memory`, `remove_monitor_url`, `set_voice_brain`) are marked destructive, so your client can ask before running them.
Credits are from your ScriptGrain plan; "free" means no credit is used.

Drafts, polish and humanise are priced by length: up to 5,000 words 1 credit,
up to 10,000 words 2, up to 15,000 words 3 (the most one piece can be). A draft
over 4,000 words, or a polish or humanise over 3,000 words, runs in the
background: the tool returns at once with a job, and `get_job` shows its
progress until it has succeeded (about a minute per 2,000 words). Credits are
charged as the words are delivered, never above the tier asked for.

### Voice profiles

| Tool | What it does | Cost |
|---|---|---|
| `list_profiles` | Lists the voice profiles your key can use, with status, confidence score and sample count | Free |
| `create_profile` | Builds a voice profile from 1 to 20 samples of your own writing (3+ pieces and 3,000+ words gives a confident profile); runs for about 1 to 3 minutes | 1 extraction slot |
| `get_profile` | A profile's status and, once complete, its narrative description and all 45 attributes | Free |
| `mimic_brand` | Builds a profile from a public brand website (up to 8 pages); asks for your explicit consent first | 1 brand-mimic credit |

### Drafting, scoring and revising

| Tool | What it does | Cost |
|---|---|---|
| `create_outline` | An outline for a long-form piece, to review before drafting | Free |
| `generate_content` | A draft in your measured voice in one of 16 content types, up to 15,000 words, with its voice-match score; 1 to 3 variants (2 and 3 up to 4,000 words); over 4,000 words it is written in the background | Per variant: 1 credit up to 5,000 words, 2 up to 10,000, 3 up to 15,000 |
| `check_voice_match` | Scores any text against a profile, with the per-feature numbers behind the score | Free |
| `compare_voice` | No profile needed: scores up to three pieces (text or URL) against a main piece | Free |
| `polish` | Revises a draft toward a voice-match target (default 0.9), up to 3 passes; over 3,000 words it runs in the background | 1 credit up to 5,000 words, 2 up to 10,000, 3 up to 15,000; free if the draft already passes |
| `humanize` | Rewrites text (or a saved draft) to remove measurable machine-writing tells while keeping every fact, up to 3 passes; over 3,000 words it runs in the background | 1 credit up to 5,000 words, 2 up to 10,000, 3 up to 15,000; free if the text already passes (up to 3,000 words) |
| `ai_detect` | Stylometric human-vs-AI reading of any text of 50+ words | Free |
| `rewrite_page` | Rewrites a public web page's copy in your voice, block by block; prices, legal lines and button labels are left alone | 1 credit per 1,500 words; paid plans |
| `save_edit` | Saves your final edit of a draft, so the profile learns from the difference | Free |
| `list_generations` | Lists past drafts with their scores | Free |
| `get_generation` | Fetches one past draft in full (while a long draft is being written, the part delivered so far) | Free |
| `get_job` | Progress of a background job (a long draft, polish or humanise): sections done, words written, credits charged, and the result once it has succeeded | Free |

### Voice Brain: the memory of what you have already written

| Tool | What it does | Cost |
|---|---|---|
| `get_memory` | The ideas, claims, stories and frameworks your writing has covered, each with a verbatim quote | Free |
| `sync_memory` | Indexes new drafts and samples into the memory | Free |
| `check_novelty` | Checks a brief against the memory: repeats, builds on, or new, with grounded angles | Free |
| `what_next` | Five angles that build on what you keep saying | Free |
| `add_to_memory` | Adds a published piece by pasted text or URL (60+ words), or one memory stated directly (`memory`, with an optional kind and topic) | Free |
| `set_repeat_policy` | Whether drafts avoid restating earlier arguments (the default) or may repeat them | Free |
| `list_brains` | Lists the memories (brains) a voice may use and which voices share each | Free |
| `set_voice_brain` | Moves a voice to another brain, or back to its own | Free |
| `edit_memory` | Changes one memory: its words, its kind, or its topic | Free |
| `delete_memory` | Deletes one memory | Free |
| `forget_piece` | Forgets a whole piece and every memory taken from it | Free |

### Voice monitor: published pages, scored monthly

| Tool | What it does | Cost |
|---|---|---|
| `get_voice_monitor` | The pages being watched, the latest run's scores and the previous run | Free; paid plans |
| `add_monitor_url` | Watches a public page (Writer and Operator 5 pages, Studio 15, Agency 50) | Free; paid plans |
| `remove_monitor_url` | Stops watching a page; past results are kept | Free |
| `run_voice_monitor` | Runs this month's check now (one run per profile per month; the scheduled run is on the 1st) | Free |

### Company context

| Tool | What it does | Cost |
|---|---|---|
| `list_companies` | Lists your company or product profiles, used to ground drafts in real facts | Free |
| `create_company` | Creates one from a URL, freeform notes or fields; only claims the pages make | Free (reading a site by URL needs a paid plan) |

### Account

| Tool | What it does | Cost |
|---|---|---|
| `get_billing` | Plan, remaining credits and renewal date | Free |
| `get_invoice` | The latest invoice with a PDF link | Free |
| `upgrade_plan` | A Stripe-hosted link to upgrade or manage the plan; nothing is charged through the connector | Free |

### Prompts

- `write_in_my_voice`: draft a piece, report its score, iterate, and save the final edit.
- `build_my_voice_profile`: gather your own writing, create the profile, and walk through the result.

## Worked examples

1. [Build a voice profile from your writing and read it](examples/01-build-a-voice-profile.md)
2. [Draft in your voice, score it, polish it, save your edit](examples/02-draft-score-polish-save.md)
3. [Check whether pages sound like one writer, with no profile](examples/03-off-voice-check-without-a-profile.md)

## Limits worth knowing

- 60 requests per minute per key.
- Five profile extractions an hour.
- Drafts are written in UK or US English.
- `mimic_brand` needs your explicit consent to analyse a website's writing.
- Payments never happen through the connector.

## Privacy and security

- With OAuth, your password is used once on the consent page and never
  stored; the grant holds an encrypted key that is never shown to the
  client, and revoking it in Settings, API ends the access.
- With a pasted key, keep the key in the client's secret store or an
  untracked config file.
- ScriptGrain receives only what a tool call contains.
- Subprocessors and data handling: https://scriptgrain.com/trust ·
  Privacy: https://scriptgrain.com/privacy · Terms: https://scriptgrain.com/terms
- Report a security issue to security@scriptgrain.com (https://scriptgrain.com/.well-known/security.txt).

## More about ScriptGrain

- The 45 attributes, one page each: https://scriptgrain.com/attributes
- How a voice is measured and scored: https://scriptgrain.com/reference/voice-measurement-framework
- Published studies, with method and limitations: https://scriptgrain.com/research
- Every MCP tool and what it costs: https://scriptgrain.com/reference/mcp-tool-reference
- For AI assistants: https://scriptgrain.com/llms.txt

## Support

support@scriptgrain.com · https://scriptgrain.com/support

ScriptGrain is a product of Adapt Progress Evolve Limited, registered in
England and Wales (10047328), London.

## Licence

The documentation and configuration files in this repository are released
under the MIT licence (see [LICENSE](LICENSE)). The ScriptGrain name, logo and
service are not covered by it.
