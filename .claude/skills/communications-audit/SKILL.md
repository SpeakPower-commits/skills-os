---
name: communications-audit
description: Run a structured communications audit for a founder, NGO or business and produce a scored, evidence-backed report with a prioritised fix plan. Reviews positioning clarity, message consistency, audience fit, channel and format fit, proof and credibility, and measurement across website, social, decks and documents. Also runs a one-page mini-audit from public assets. Use for "communications audit", "comms audit", "audit our messaging", "why isn't our brand landing", "review our LinkedIn and website", "SpeakPower audit", or when a prospect needs Tom's headline audit offer scoped and delivered.
metadata:
  domain: comms
  command: audit
  version: "0.1.0"
---

# Communications Audit

Plays the lead auditor on SpeakPower's headline offer. Examines how an organisation communicates, scores it on six dimensions with cited evidence, and returns a report whose fixes are ranked by impact and effort.

## When to use it, and when not

- Use when: a client or prospect wants to know what is wrong or missing in their communications, or Tom needs a mini-audit to open a conversation.
- Do not use when: the target is code, security or SEO only (use `/audit` with `searchfit-seo:seo-audit` or `code-review`), or the job is to write new content (use `speakpower-comms-strategist`).
- Hand off after the audit: positioning gaps go to `brand-positioning-architect`; the paid next step goes to `consulting-proposal-and-scope`.

## Inputs

- Client name, objective (what the communications must achieve), target audiences, and the assets in scope.
- Access level. Default is public assets only. Anything private (analytics, internal documents, drafts) needs the client to supply it.
- Time window (default: the last 6 months of public activity).

## Method

1. **Scope and consent.** Write the scope in five lines. Confirm what Tom may look at and what stays confidential. Do not log in to any client account.
2. **Capture evidence.** Inventory the assets: website pages, LinkedIn and other social profiles, WhatsApp channels if shared, decks, proposals, newsletters, reports, signage. Sample by rule and state it (for example the last 20 posts, the 10 most important pages, 3 key documents). Record URL or file, date and a note for each item. Use `firecrawl` for public pages. Mark anything not seen as "not examined".
3. **Score six dimensions from 0 to 4** (0 absent, 1 weak, 2 partial, 3 solid, 4 exemplary). Each score cites at least two evidence items.
   - Positioning clarity: in five seconds, can a stranger say who it is for, what it does and why it is different?
   - Message consistency: is the same promise and vocabulary used across channels and documents?
   - Audience fit: does the content speak to the audience the client says it wants, and is there evidence of who actually responds?
   - Channel and format fit: are the channels where the audience is, with a workable cadence, language, mobile and low-bandwidth access?
   - Proof and credibility: named results, testimonials, data, and for NGOs the governance signals (registration, reports, financial transparency).
   - Measurement and governance: goals, KPIs, ownership, approvals, brand guidelines.
   - Weight the dimensions to the client's objective. Show the weights; they sum to 100.
4. **Write findings.** For each: what was observed, the evidence, why it matters in the client's terms, the fix, effort (hours, days, weeks) and the metric that will show it worked. Rate severity as Critical, High, Medium or Low.
5. **Build the fix plan.** Quick wins in 14 days, then a 30, 60 and 90 day sequence. Put the single biggest lever at the top. Include one **Wildcard** recommendation that breaks from the obvious.
6. **Separate what is observed from what is inferred.** Without analytics access, effectiveness claims are inferences. Say so.
7. **Write the report.** Executive summary (one page), scorecard, findings, plan, evidence log. Produce it as a document or deck with the `anthropic-skills:docx` or `anthropic-skills:pptx` skill. Lead the debrief with what is working.

## Mini-audit mode

For lead generation, from public assets only, in 60 to 90 minutes: the five-second test on the homepage and LinkedIn profile, three consistency checks, the five most consequential findings, and one quick win. One page. Send it to the prospect only with Tom's OK, and never publish a critique of an organisation that has not asked for one.

## Output

The scorecard, ranked findings, the fix plan and the evidence log, plus the metrics that prove it worked: the five-second test pass rate re-run at 90 days, the consistency score re-run at 90 days, and, for SpeakPower, the share of audits that convert to a strategy engagement.

## Guardrails

- Never invent benchmarks or competitor figures. Cite a retrieved source or leave it out.
- State the sample size and what was not examined in the report.
- Client material stays confidential. Do not reuse a client's data in another deliverable without consent.
- Sending the report or any outreach to the client needs Tom's explicit OK.
