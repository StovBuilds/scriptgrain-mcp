# Example 1: build a voice profile from your writing and read it

**You need:** a ScriptGrain account (Free is enough: one profile, one
analysis) and three or more pieces you wrote yourself. 3,000 words or more
across them gives a confident profile; one piece is enough to start. Paste
human-written prose only: an AI draft gives the profile the wrong voice.

## Ask your assistant

> Build my ScriptGrain voice profile from these three posts I wrote. Call it
> "My newsletter voice". Then walk me through what it found.
>
> [paste the three posts]

Or use the server's built-in prompt `build_my_voice_profile`, which gathers
the samples with you and confirms before it creates anything.

## What happens

1. The assistant calls `create_profile`:

   ```json
   {
     "samples": ["<post one>", "<post two>", "<post three>"],
     "name": "My newsletter voice",
     "english_variant": "uk"
   }
   ```

   This uses one extraction slot from your plan. Extraction runs in the
   background for about one to three minutes (five extractions an hour at
   most).

2. It polls `get_profile` with the returned `profile_id` about every ten
   seconds. While the analysis runs, the response carries `progress_percent`.

3. When `status` is `complete`, `get_profile` returns the narrative
   description of how you write and all 45 measured attributes, with the
   profile's confidence score.

## Reading the result

Ask for the parts that are hard to see in your own writing:

> Which five attributes are most distinctive about me, and what are the
> numbers?

The assistant should quote the measured values it received rather than
describe them loosely; each attribute is explained at
https://scriptgrain.com/attributes (what it measures, how it is scored, its
API field name). Stored values are the extraction model's reading of your
samples; when a draft is scored, code counts 14 of the features directly and
a model judges the rest.

To see finished profiles before you build your own:
https://scriptgrain.com/voice-preview
