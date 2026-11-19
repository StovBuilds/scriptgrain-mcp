---
name: scriptgrain
description: Write in a person's own measured voice with the ScriptGrain MCP server. Use when the user wants AI drafts that sound like them, wants to build a voice profile from their own writing, score a draft or any text against their voice (0 to 1, with the measured numbers), polish a draft toward their voice, check whether pages sound like one writer, or avoid repeating what they have already written. Needs the remote server https://mcp.scriptgrain.com/mcp (OAuth or a ScriptGrain API key, every plan including Free); https://mcp.scriptgrain.com/try works with no account.
license: MIT
metadata:
  server: https://mcp.scriptgrain.com/mcp
  server-version: 1.23.1
  homepage: https://scriptgrain.com
---

# ScriptGrain: write in the user's measured voice

ScriptGrain measures a writing voice from writing the person has already done:
45 attributes in eight groups (lexical, syntax, tone and register, rhetoric,
punctuation and format, function words, content patterns, quirks and cadence).
It drafts in that voice and scores any text against it from 0 to 1, with the
per-feature numbers behind the score. This skill is the working method for its
remote MCP server; the tools do the measuring, so report what they return and
never estimate a score yourself.

## Connect

- Endpoint: `https://mcp.scriptgrain.com/mcp` (streamable HTTP; every POST is
  answered as plain JSON). Legacy SSE: `https://mcp.scriptgrain.com/sse`.
- Auth: OAuth (the client opens ScriptGrain's consent page), or the header
  `Authorization: Bearer sg_live_...` with a key from
  https://scriptgrain.com/settings?tab=api. Every plan, including Free, has
  access. Keep a key out of version control.
- Cursor (`.cursor/mcp.json` or the global settings):

  ```json
  { "mcpServers": { "scriptgrain": { "url": "https://mcp.scriptgrain.com/mcp" } } }
  ```

- Claude Code: `claude mcp add --transport http scriptgrain https://mcp.scriptgrain.com/mcp`

If the server's tools are not available in this session, say so and point the
user to https://github.com/StovBuilds/scriptgrain-mcp to connect it. Do not
imitate the tools by guessing scores or attributes.

### No account yet: the guest server

`https://mcp.scriptgrain.com/try` needs no key or sign-in. Call `start_session`
first: it returns a `guest_token` (pass it to every other call), a `claim_url`
and the limits. A guest gets one voice profile, one extraction and no drafts,
with `create_profile`, `get_profile`, `check_voice_match`, `compare_voice` and
`claim_status`. Give the person the `claim_url`: it keeps the profile in a free
account or deletes it. Unclaimed sessions are archived after 7 days. At most 3
sessions a day from one network, so reuse the token you have; checks are 5 an
hour per network.

## Workflow 1: build a voice profile

1. Gather writing the user wrote themselves: messages they typed to you,
   documents or emails they shared, posts of theirs you can read. Use their
   exact words. Never send your notes or summaries about them, and never text
   you or another AI wrote or rewrote: that would measure the wrong voice.
2. Tell the user which pieces you are about to send, then call
   `create_profile`. 1 to 20 samples, each under 5,000 words; a sample needs
   50+ words to count; 3+ samples totalling 3,000+ words gives a confident
   profile. It uses one of the plan's extraction slots (5 extractions an hour).
3. Show the user `samples_used` from the result (each piece's first line and
   word count).
4. Poll `get_profile` about every 10 seconds until `status` is `complete`
   (usually under a minute). Then read them the narrative and the attributes
   that stand out.

To build a profile from a public brand website instead, `mimic_brand` asks for
the user's explicit consent that they own or may use the site. Get it first.

## Workflow 2: draft, score, polish, save

1. `list_profiles` to find the `profile_id`; ask if there are several.
2. Optional, before writing: `check_novelty` with the brief. It says whether
   the idea `repeats`, `builds_on` or is `new` against the profile's Voice
   Brain memory, and offers grounded angles; put the chosen angle in the brief.
   `what_next` proposes five angles when the user asks what to write about.
3. Long pieces: `create_outline` (free), agree it with the user, then pass its
   `generation_id` to `generate_content`.
4. `generate_content` with `profile_id`, `brief` and `content_type`, one of:
   `article`, `linkedin`, `newsletter`, `email`, `short_story`, `social_post`,
   `twitter_thread`, `instagram_caption`, `blog_intro`, `press_release`,
   `product_description`, `ad_copy`, `website_landing`, `website_home`,
   `website_product`, `website_about`. Optional: `word_count_target`,
   `register`, `english_variant` (UK or US English), `variants` (1 to 3).
   Check `within_tolerance` (within 15% of the target) before calling a draft
   on length, and report `voice_match_score`.
5. Over 4,000 words the draft is written in the background: the call returns
   a job at once. Poll `get_job` every 30 to 60 seconds (about a minute per
   2,000 words). A job that stops part way keeps what it delivered.
6. If the score falls short, `polish` revises toward a target (default 0.9),
   up to 3 passes, and returns the best version with its per-feature deltas.
   It is free when the draft already clears the target.
7. After the user edits, `check_voice_match` (free) scores the edited text.
8. When the user is happy with the final text, `save_edit` with the
   `generation_id` and their final version. The difference feeds the
   profile's learning, so later drafts start closer.

`humanize` is a different job: it rewrites text to remove measurable
machine-writing tells while keeping structure, tone and every fact, with no
profile. If both are wanted, polish first and humanize last.

## Workflow 3: does this sound like one writer? (no profile needed)

`compare_voice` scores up to three pieces (pasted text of 120+ words, or a
public URL) against a main piece. Bands: 0.8+ on voice, 0.55 to 0.8 drifting
(common for two short pieces by one writer), below 0.55 off voice. Report
`top_differences` and `top_matches` with their numbers. Free.

## Reading scores

- Profile scores (`check_voice_match`, drafts): on-voice text typically scores
  0.85 to 0.95, partial matches 0.5 to 0.8, below 0.45 is clearly another
  voice.
- Quote the `deltas` numbers (draft value against profile value) when you
  explain a score. Do not invent detail the measurement did not return.
- Read `score_context`: short samples and deliberately brief formats score
  low for structural reasons, not because the voice is wrong.

## Costs

Scoring, outlines, reading, memory and saving edits are free. Drafts, polish
and humanise use plan credits by length: up to 5,000 words 1 credit, up to
10,000 words 2, up to 15,000 words 3 (the longest one piece can be); each
extra variant costs its own credit. `rewrite_page` is 1 credit per 1,500 words
on paid plans. If a call is refused for credits, `get_billing` shows the plan
and what is left; `upgrade_plan` returns a Stripe-hosted link, and nothing is
ever charged through the connector. Limits: 60 requests a minute per key.

## Ask before these

The server marks these tools destructive, so confirm with the user first:
`delete_memory`, `forget_piece`, `edit_memory`, `set_voice_brain`,
`remove_monitor_url`, `delete_brief_template`, `restore_draft_version` and
`save_edit` (saving again replaces the previous edit for that draft).

## Other tools

- Voice Brain memory: `get_memory`, `sync_memory`, `add_to_memory`,
  `set_repeat_policy`, `list_brains`.
- Voice monitor (paid plans, monthly scores for published pages):
  `get_voice_monitor`, `add_monitor_url`, `run_voice_monitor`.
- Company facts to ground drafts: `list_companies`, `create_company`
  (`company_id` on `generate_content`).
- Saved briefs: `list_brief_templates`, `save_brief_template` (`template_id`
  on `create_outline` or `generate_content`).
- History: `list_generations`, `get_generation`, `list_draft_versions`.
- Detector: `ai_detect` reads any text of 50+ words as human or AI, free.
- Account: `get_billing`, `get_invoice`, `upgrade_plan`.
- Prompts: `write_in_my_voice`, `build_my_voice_profile`.

The full tool list with costs: https://scriptgrain.com/reference/mcp-tool-reference
and https://scriptgrain.com/docs/mcp.md. Data handling (writing is measured,
never trained on): https://scriptgrain.com/trust.
