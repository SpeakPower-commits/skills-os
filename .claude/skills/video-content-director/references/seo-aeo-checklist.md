# SEO / AEO / GEO Checklist for Video & Audio Content

Reference this for Step 6 of the main pipeline. Video/audio discoverability now runs on three overlapping layers — cover all three, not just classic SEO.

## 1. Classic platform SEO
- Title: primary keyword near the front, under platform truncation limits (YouTube ~60 chars visible)
- Description: first 1–2 lines do the work before "show more" truncates — restate the keyword and the specific value, not a generic teaser
- Tags/categories: match actual search-demand terms, not brand jargon
- Thumbnail (Canva asset): should visually reinforce the title's promise, not just look polished

## 2. AEO (Answer Engine Optimization)
AI answer engines (and YouTube/Google's own AI overviews) pull from structured, chunkable content — not narrative prose.
- Provide a timestamped or section-based transcript, not just a raw wall of text
- Frame at least 3–5 chunks as an explicit question the content answers ("What is X" / "How does Y work") even if the video itself isn't scripted as Q&A — the metadata layer can be
- Keep each answerable chunk self-contained (a snippet lifted alone should still make sense)

## 3. GEO (Generative Engine Optimization) / grounding
- Cite specific, checkable facts or data points in the transcript/description rather than vague superlatives — generative engines and readers alike weight specificity
- For UBF/FoB content, ground claims in the institutional sources already established in UBF strategy (UBOS, World Bank, CBD, BIOFIN) rather than generic conservation claims
- Structured data: recommend `VideoObject` schema (or `PodcastEpisode` schema for audio) when the asset lives on an owned page — name, description, thumbnailUrl, uploadDate, duration at minimum

## Keyword sourcing discipline
Never invent search-volume numbers. If SEMrush/Ahrefs-style data isn't available in-session, say so explicitly and reason from category logic (competitor content gaps, question-based search patterns, platform autocomplete behavior) instead of presenting a guess as a figure.
