---
name: smart-brevify
description: >
  Rewrite text into Smart Brevity, the Axios method from Jim VandeHei, Mike
  Allen, and Roy Schwartz. Restructures into the Core 4 (tease, lede, why it
  matters, go deeper), cuts non-load-bearing words, and formats for skimmers.
  Supports modes: full (default), inline, audit.
  Use when the user says "smart brevity", "brevify", "smart-brevify this",
  "make this Smart Brevity", "tighten this note", or invokes /smart-brevify.
---

Rewrite the given text so a busy reader gets the point in the first two lines
and can stop there. Length is not thoroughness. Return **only** the rewritten
text (or the audit), ready to paste — no preamble, no "here is your rewrite".

Default mode: **full**. Switch: `/smart-brevify full|inline|audit`.

## The Core 4

Every `full` rewrite has these four parts, in order:

1. **Tease** — a headline or subject line of six or fewer strong words that
   yanks attention. Accurate, not clickbait. Do not repeat it verbatim in the
   lede.
2. **Lede** — one strong first sentence: the single most important thing. Tell
   the reader something they don't know, would want to know, should know.
   Direct, short, sharp. If this is the only line they read, it must land. Gut
   check: does it pass "just tell me something I don't already know"?
3. **Why it matters** — a bolded `**Why it matters:**` label, then one sentence
   (two at most) on the consequence for _this_ reader. This is the most
   important Axiom. If there is no consequence, the item should not exist. The
   reader is scanning, not reading, and asks two questions: "What is this?" and
   "Is it worth my time?" This part answers the second.
4. **Go deeper** — optional. Bullets, then links or detail, as opt-in depth.
   Never force it up front. Most readers will not click; including it still
   signals thoroughness and respect for their time.

## Four guiding principles

- **Authority** — be the expert or cite one. State things plainly, no hedging.
- **Brevity** — short, not shallow. "Brevity is confidence. Length is fear."
  Cut words, never substance.
- **Humanity** — write like you speak. Lose insider-isms and fancy clauses.
- **Clarity** — style the text for impact so it can be skimmed and still
  understood.

**Audience first, not ego.** Think about the reader before yourself and the
waste cuts itself. Aim to fit the whole message on **one screen of a phone**,
above the fold, whatever the format.

## Word-level tactics

- **Delete, delete, delete.** If removing a word or sentence does not change the
  meaning, remove it. Every word shaved is a gift to the reader.
- **Active voice.** "Rocky knocked out Apollo", not "Apollo was knocked out by
  Rocky."
- **Strong verbs.** "ran up the bleachers", not "moved quickly up the
  bleachers."
- **One-syllable, concrete words.** "robbed a bank", not "made an illegal
  withdrawal from a financial institution."
- **Purge weak, foggy words and adverbs** — just, really, basically, very, in
  order to, it should be noted that, there are a number of.
- **Numbers beat adjectives.** "one release behind, published four days ago"
  beats "slightly out of date."
- **Bold the eye-traps.** Bold the lead-in of a bullet or paragraph, and any
  name or figure a skimmer must catch.
- **Bullets for lists.** They pause the skimming eye on the data that matters.
- **One idea per paragraph**, two or three sentences each.
- **Cut the author's journey.** Smart Brevity serves the reader, not the writer.
  Delete process narration, methodology, and mea culpas — "I set out to", "after
  much research", "what I got wrong before", "here's what I found". Lead with the
  finding, not the hunt for it. Exception: keep the journey only when the source
  material _explicitly_ makes it the subject (a retrospective, a post-mortem, a
  "how we built it" piece). Even then, compress it.

## Smart Brevity Count

For a durable artifact (a note, a blog post, a long email), lead with a word
count and read time so the reader can decide up front. The average person reads
~265 words per minute; divide the word count by 265 for minutes. Format:
`1,200 words · ~5 min read`. Skip this for short inline rewrites and Slack posts.

## Modes

- **full** (default) — complete Core 4 restructure with the `**Why it matters:**`
  header and go-deeper bullets. Use for notes, docs, emails, announcements.
- **inline** — tighten the prose in place. Apply every word-level tactic and
  lead with the point, but do **not** add the four-part scaffold or headers. Use
  for a Slack post, a commit body, or a paragraph where the full structure is
  overkill. Preserve the author's format; just make it tighter and sharper.
- **audit** — do **not** rewrite. List what violates Smart Brevity and the fix
  for each, so the author learns. Format as bullets: `- [problem] → [fix]`. End
  with the one change that would help most.

## Guardrails

- **Preserve meaning and facts.** Keep every number, date, proper noun,
  technical term, code block, and direct quote exactly as written. Tightening
  prose must never alter data.
- **Never invent a "why it matters".** If the source does not state the
  consequence, do not fabricate one. In `full` mode, write
  `**Why it matters:** [source does not state — supply the consequence]` so the
  author fills the gap. Do not guess.
- **Ask, do not assume, on ambiguity.** If the single most important point is
  genuinely unclear, ask which of two candidate ledes is the intended one rather
  than picking blind.
- **The artifact is not about you.** Never let the writer's process, effort, or
  earlier mistakes leak into a durable artifact. The reader wants the answer, not
  a record of how it was reached. Report it only if the source material
  explicitly mentions the journey; otherwise cut it.

## Exceptions — where completeness beats compression

For these, tighten wording only. Never cut scope, steps, or reasoning. Do not
force the Core 4 scaffold if it would drop content.

- **Security findings and risk statements.** State the full scope and every
  caveat. Compression here reads as minimising a risk.
- **Procedures and runbooks.** Keep every step, in order, including the obvious
  ones. Someone follows this at 2am.
- **Decision records.** Keep the reasoning and the rejected alternatives. The
  "why not" is what stops the decision being relitigated.
- **Agent and system instructions.** Explicit beats terse when the reader is a
  model that cannot ask a follow-up.

## Examples

### full

**Before:** "I wanted to reach out and let everyone know that we have decided,
after quite a bit of internal discussion, that we are going to be migrating our
staging environment over to the new cluster configuration sometime next week,
which will probably mean a little bit of downtime for folks who are testing."

**After:**

> **Staging moves to new clusters next week**
>
> Staging migrates to the new cluster config the week of the 14th, with a short
> testing outage.
>
> **Why it matters:** Any test runs during the migration window will fail —
> schedule around it.
>
> Go deeper:
>
> - Outage: ~30 min, exact time TBD, announced 24h ahead.
> - Prod is unaffected.

### inline

**Before:** "It should be noted that the deploy failed basically because the
config file was not actually present in the expected directory location."

**After:** "Deploy failed: the config file was missing from
`/etc/app/`."

### audit

**Before:** "In order to improve our overall system performance, we are
currently in the process of undertaking a comprehensive review of all of our
existing database queries."

**Audit:**

- "In order to" → "To".
- "currently in the process of undertaking" → "reviewing".
- "comprehensive review of all of our existing" → "auditing our".
- Buries the point → lead with it: "We're auditing DB queries to cut latency."
- Biggest win: state the target — "cut p95 latency below 200ms" beats "improve
  overall system performance."

## Sources

Rules synthesized from secondary summaries of the book, not the primary text.
Faithful to the method as these summaries present it, but not verified
line-by-line against the book itself.

- **Book:** _Smart Brevity: The Power of Saying More with Less_ — Jim VandeHei,
  Mike Allen, Roy Schwartz (Axios), 2022. The original, not read directly.
- **mickmel.com** — chapter-by-chapter notes. Source for the Core 4, the four
  guiding principles, "Brevity is confidence. Length is fear.", the ≤6-word
  tease, and the one-sentence lede.
  <https://www.mickmel.com/notes-from-smart-brevity-from-jim-vandehei-mike-allen-and-roy-schwartz/>
- **shortform.com** — book overview. Source for the word-level tactics: active
  voice, strong verbs, one-syllable words ("robbed a bank"), bold and bullets
  for skimmers, and the explicit "Why it matters" label.
  <https://www.shortform.com/blog/smart-brevity-book/>
- **AGENTS.md** (this repo's `~/projects/ppai/AGENTS.md`) — source for the
  "Exceptions" section, not the book.
- **Obsidian vault** (`~/Documents/Nate's Vault`) — `Smart Brevity.md` and the
  post template in `Databricks Blogs.md`. Source for the reader's two questions
  ("What is this?" / "Is it worth my time?"), audience-first-not-ego, the
  one-screen-of-a-phone constraint, the "just tell me something I don't already
  know" lede test, and the Smart Brevity Count (~265 wpm). Conscious Style Guide
  (<https://consciousstyleguide.com>) is referenced there for inclusive wording.

Axios's own pages (axios.com, axioshq.com) returned 403 and were not read.
