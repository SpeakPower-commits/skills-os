---
name: tom-voice-article-writer
description: Write a long-form article (about 800 to 1,200 words) in Tom's own voice for LinkedIn and the blog, with the data, the graphics and every publishing format ready. Use for "write an article", "1000-word article", "blog post and LinkedIn article", "write it like the audit one", "article in my voice", or any long piece for SpeakPower or a venture where it must read as human-written. Produces the article, SEO block, chart and framework graphics, Word and PDF editions, and a LinkedIn upload folder with plain text and images kept separate.
metadata:
  domain: comms
  command: campaign
  version: "0.1.0"
---

# Tom's voice article writer

Writes a long article that sounds like Tom talking, not like a content tool, and packages it so it can actually be published. The model piece is `lab/article-comms-audit/article.md` ("I Audited My Own LinkedIn"). Tom read it and said it was written in his own voice. Match it.

## When to use it, and when not

- Use when: Tom wants a long article for his LinkedIn, a blog, or both, in his voice.
- Do not use when: it is a short LinkedIn post, a caption or outreach copy (use `speakpower-comms-strategist`), UBF/FoB institutional writing (use `ubf-comms-strategist`), or a client deliverable such as an audit report (use `communications-audit`).

## Inputs

- Needed: brand (default SpeakPower) and topic. If the topic is missing, offer three options with a recommended one and a labelled Wildcard, and ask once.
- Infer, do not ask: service line, Daily_Calendar pillar, audience (the target one: founders and NGO leaders), offer order (audit first, coaching second, software third), length (about 1,000 words), formats (all of them).
- Find, do not invent: one real data point or client detail with its source and date. Tom's own analytics are the best source. If none is on hand, say so and offer to search.

## Method

1. **Place it.** Name the service line, the pillar and whether it is written for the target or the current audience. Pull toward the target.
2. **Ground it.** Choose the one fact the piece stands on. List every claim that rests on an assumption (an event that happened, a cadence, a promise made in Tom's name). These go in the pre-publish checks.
3. **Find the turn.** The strongest shape so far: a first-person admission backed by a number, then a turn ("the message was fine, the match was wrong"), then the method, then why it hits his audience harder, then a do-it-yourself version, then what Tom will do and report back on. Never invent the event; build the story from evidence he has.
4. **Draft in his voice** (rules below). Aim for 1,000 words, then count with a script and adjust to within about 20.
5. **Run the human check** (below) and fix what it catches.
6. **Make the visuals.** At minimum: a cover, one data graphic with the real numbers, one framework graphic, one shareable checklist card. Use only real human photos from Tom's own files. Never use a colleague's or third party's photo without consent. If generators are blocked, say so and design in HTML, rendering to PNG with headless Edge.
7. **Package it** (see Output). Check every render by looking at it.
8. **Present** with the pre-publish checks, the metric that proves it worked, and a labelled Wildcard.

## Voice rules (taken from the approved article and Tom's own earlier pieces)

- Mostly one-sentence paragraphs. Deliberate fragments: "Six." "Just not the one that hires a strategist."
- Connectors ("But", "So", "And", "Yet") only at real pivots, not on every paragraph.
- Spoken English kept as spoken: "All you've to do is this." Contractions throughout.
- Light humour in brackets, once or twice: "(Yes, the audit consultant needed an audit. I'll wait while you enjoy that.)"
- One or two local touches that are true and specific: airtime, a programme officer who also runs the Facebook page, a WhatsApp broadcast. No clichés about Africa or "the continent".
- Subheads are plain statements or questions Tom would say aloud, not marketing labels.
- Numbered lists use bold lead-ins. Time boxes and numbers are concrete.
- Evidence over adjectives. Specific nouns, short verbs.
- Close on one short reflective question ("Who is actually reading yours?"), after the call to action.
- The call to action is soft and audit-first: "message me, I'll tell you which of the six is costing you most."

## Human check

Before presenting, read the draft for these and remove them:

- Em dashes (zero), emojis, "In today's fast-paced world", "delve", "landscape", "leverage", "unlock", "seamless", "game-changer".
- Tidy rule-of-three lists everywhere, and more than two "it's not X, it's Y" turns.
- Paragraphs all the same length, or every sentence opening the same way.
- Claims with no source, and numbers that are too round.
- Advice that could appear in any article on the topic. Every point should trace to Tom's data, a named client (with consent) or a stated method.

## Output

Write to `lab/<article-folder>/` (never live):

- `article.md` with a publish block (SEO title under 60 characters, meta description under 155, slug, target keyword, service line, pillar, audience) and alt text under each image.
- `article.html` for review and the blog.
- `images/`: cover, data graphic, framework, checklist card, plus the two human photos for the Word edition. Palette: navy `#0D172A`, gold `#F2B720`, cream `#FBF6EA`. Headings in Bahnschrift. The SpeakPower logo file is only 265px, so keep it small.
- `<slug>.docx` (A4, built with the `docx` npm package) and `<slug>.pdf` (exported by real Word through 32-bit PowerShell, because 64-bit resolves to WPS).
- `linkedin-upload/`: a plain-text article with `[INSERT IMAGE]` markers, a plain-text feed post, the images resized and numbered, and a how-to. **Always keep text and images separate for LinkedIn.** Pasting rich text or Word content into LinkedIn has failed for Tom.
- `README.md`: files, pre-publish checks, metric, Wildcard.

The build scripts are in `lab/article-comms-audit/src/` (`render.ps1`, `build-html.ps1`, `prep-photos.ps1`, `build-docx.js`, `export-pdf.ps1`, `build-linkedin.ps1`). Reuse them. When this skill is promoted, copy them into the skill's `scripts/` folder.

## Visual variety (hard rule, added after Tom said the second article looked like a copy of the first)

Every article gets its own visual identity. Two articles side by side must not look like the same template.

1. **Read `references/visual-log.md` before designing anything.** It lists the concept, typography and photos used by each earlier article.
2. **Pick a concept not yet used** and write it into the log before you start. Concepts to rotate through: dark cards and dashboard; paper and ink (handwriting, sticky notes, red-pen edits); editorial photo poster; field notebook (maps, sketches); bold typographic poster; geometric blocks; Swiss grid data poster. Invent others.
3. **Brand anchors are only these:** navy and gold somewhere, and the small logo badge. Everything else changes between articles: dominant colour, layout, type pairing, illustration style, how the framework graphic is drawn. A grid of numbered cards is allowed once.
4. **Photos are never reused** across articles, except Tom's author portrait. The cover must not be the previous article's cover.
5. **Where photos come from, in order:** Tom's own files; free-licence stock (Pexels, Unsplash) that Tom has approved by file name, source and size before any download; AI generation only if a generator works. Avoid photos of children and of real people presented as a specific beneficiary.
6. **Before presenting, put the new cover next to the last one.** If a stranger would call them the same series template, redo them.
7. Add the new article's row to the visual log in the same commit.

## Guardrails

- Never invent figures, client results or partnerships. Name unverified numbers in the README and ask Tom to confirm them against his analytics before publishing.
- Do not name a client or publish a critique of an organisation that has not agreed to it.
- Flag every commitment made in Tom's name (a follow-up report, a free offer).
- Say where each photo came from and whether its licence is known.
- Get Tom's approval before publishing or posting anything. Drafts stay in `lab/`.
- Name the metric that proves it worked and its baseline. Do not invent a target.
