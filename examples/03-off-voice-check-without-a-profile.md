# Example 3: check whether pages sound like one writer, with no profile

**You need:** any ScriptGrain account (Free is enough). No voice profile is
needed and no credit is used.

This is the question an editor, an agency or a founder asks about a
website: does the blog still sound like the about page? `compare_voice`
measures a main piece, turns it into a temporary baseline, and scores up to
three other pieces against it.

## Ask your assistant

> With ScriptGrain, compare these three blog posts against our about page and
> tell me which one drifts furthest from our voice, with the numbers.
>
> Main: https://example.com/about
> Others: https://example.com/blog/post-one, https://example.com/blog/post-two,
> https://example.com/blog/post-three

## What happens

`compare_voice` is called with the main piece and up to three others; each
can be a public URL (the page's prose is read, menus and footers skipped) or
pasted text of 120 words or more:

```json
{
  "main": { "label": "About page", "url": "https://example.com/about" },
  "others": [
    { "label": "Post one", "url": "https://example.com/blog/post-one" },
    { "label": "Post two", "url": "https://example.com/blog/post-two" },
    { "label": "Post three", "url": "https://example.com/blog/post-three" }
  ]
}
```

Each piece comes back with a `score` from 0 to 1, a `band`, and
`top_differences` and `top_matches` with the measured numbers behind them.
The scale is calibrated for pairs: 0.8 or more reads as on voice (the same
writer), 0.55 to 0.8 as drifting, and below 0.55 as a different voice.

Ask the assistant to quote the numbers rather than summarise them, for
example which features moved and by how much, then decide what to rewrite.

## Next steps

- Build a proper profile from the pages that sound right (example 1) and
  score everything against that instead.
- On a paid plan, `add_monitor_url` watches the pages and re-scores them
  against the profile every month, and `rewrite_page` rewrites a page that
  has drifted, in the profile's voice, leaving prices, legal lines and button
  labels alone.
- The same check runs in the browser, free and without an account:
  https://scriptgrain.com/tools/brand-voice-consistency-checker
