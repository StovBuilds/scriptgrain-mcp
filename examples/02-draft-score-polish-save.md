# Example 2: draft in your voice, score it, polish it, save your edit

**You need:** a complete voice profile (example 1) and generation credits:
each draft uses one (plans and credits: https://scriptgrain.com/pricing).
Scoring, outlines and saving edits are free; without credits the assistant
gets a clear `out_of_credits` error.

## Ask your assistant

> Using my ScriptGrain voice, write a LinkedIn post about why we moved our
> weekly status meeting to a written update. About 200 words. Tell me the
> voice-match score.

Or use the server's built-in prompt `write_in_my_voice`.

## What happens

1. `list_profiles` finds the profile id (the assistant asks if you have
   several).

2. `generate_content`:

   ```json
   {
     "profile_id": "<your profile id>",
     "content_type": "linkedin",
     "brief": "Why we moved our weekly status meeting to a written update.",
     "word_count_target": 200
   }
   ```

   The response carries the draft, `voice_match_score` (0 to 1), short notes
   rendered from the measured differences, and a length check
   (`word_count`, `within_tolerance`, within 15% of the target). On-voice
   drafts typically score 0.85 to 0.95; partial matches 0.5 to 0.8.

3. If the score falls short, ask for a polish:

   > Polish it toward 0.9.

   `polish` measures the draft against the profile, revises the specific
   features that diverge, and re-measures, up to three passes. It costs one
   credit, or nothing if the draft already clears the target.

4. Edit the draft yourself, or ask the assistant to, then check the edit is
   still you with the free `check_voice_match`:

   ```json
   { "profile_id": "<your profile id>", "text": "<your edited post>" }
   ```

   It returns the score plus a `deltas` array: each measured feature, the
   draft's number against the profile's, and how close they are.

5. When you are happy, say so. The assistant calls `save_edit` with the
   `generation_id` and your final text. The difference between the draft and
   your final version feeds ScriptGrain's closed-loop learning, so later
   drafts in that profile start closer.

## Before you write: avoid repeating yourself

Once a profile's memory holds some of your pieces, ask first:

> Have I already made this argument? Check it with ScriptGrain.

`check_novelty` answers repeats, builds on, or new, with the closest earlier
pieces quoted and up to three angles that add something. It is free.
