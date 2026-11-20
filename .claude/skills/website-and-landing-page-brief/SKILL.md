---
name: website-and-landing-page-brief
description: Brief and plan a website or landing page that converts for a founder, NGO or business in Uganda and East Africa. Defines the page goal, structure, copy, calls to action, SEO and AI-search basics, performance and accessibility for low-bandwidth mobile, analytics, and a build handoff. Use for "website brief", "landing page", "redo my website", "what should my homepage say", "website copy", "will this site get found", "WhatsApp button on my site", or before any web build.
metadata:
  domain: comms
  command: build
  version: "0.1.0"
---

# Website and Landing Page Brief

Plays the digital strategist who sits between positioning and the build. Produces a brief precise enough that a developer, or Tom, can build the page without guessing what it must say or achieve.

## When to use it, and when not

- Use when: a site or landing page is being created or rebuilt, or a client asks why their site is not producing enquiries.
- Do not use when: the task is a technical SEO crawl (use `searchfit-seo:seo-audit`), a code build with no brief question (use `/build` and `serverless-engineering-standards`), or a review of existing content across channels (use `communications-audit`).

## Inputs

- The positioning and message house. If missing, run `brand-positioning-architect` first or state the assumptions.
- The audience brief and the main thing visitors must do.
- Existing site address, analytics access if any, and brand assets.

## Method

1. **Set the goal.** One primary conversion (book an audit call, send a WhatsApp message, apply, donate, sign up) and one secondary. Record the baseline if one exists.
2. **List the visitor's first questions.** The five things a visitor needs answered in ten seconds: what is this, is it for me, can I trust it, what does it cost or involve, what do I do next.
3. **Design the structure.**
   - Business or consultancy: hero (promise, who it is for, one CTA), proof strip, the problem and approach, the offers, a case study, the person or team behind it, FAQ, final CTA, contact.
   - NGO: what we do and for whom, verified impact figures, programmes, how to give or partner, governance and reports, contact.
   - Landing page: one goal, no navigation, one repeated CTA.
4. **Write the copy.** Three hero options (one is the **Wildcard**), a subhead, CTA labels that name the action and outcome, and short microcopy. Use the message house. Write in plain, spoken English the audience uses. Every claim must have proof on the page or be removed.
5. **Design for the real device.** Assume a mid-range Android phone on mobile data. Set a page-weight budget and test it, compress images, keep to one or two fonts, lazy-load below the fold, no autoplay video, no heavy carousels, readable with slow scripts. Test with Lighthouse through `chrome-devtools` on public pages.
6. **Plan contact paths.** A WhatsApp click-to-chat link with a prefilled message, tap-to-call, email, and a short form with the fewest fields. For paid offers, show the payment methods clients use.
7. **Plan findability.** Page titles, descriptions and headings that match what people search for, structured data for the organisation or person and for the FAQ, a Google Business Profile where relevant, and consistent naming everywhere. For AI-search answers, write short, quotable definitions and an FAQ, and show who wrote the page and their credentials. Use the `searchfit-seo` skills for detail.
8. **Cover trust and compliance.** A privacy notice and consent for forms and analytics that fits Uganda's Data Protection and Privacy Act, 2019 (confirm specifics with counsel), accessible contrast and alt text, and no unverified claims.
9. **Plan measurement.** Events for CTA clicks, WhatsApp clicks and form submissions, campaign tags on links, a weekly review, and the threshold that counts as success.
10. **Prepare the build handoff.** An acceptance checklist, a content freeze date, and the stack. For Tom's builds, follow `serverless-engineering-standards`: static pages on GitHub Pages first, with no secrets in browser code.

## Output

A brief of two to three pages: goal and baseline, visitor questions, page outline, copy deck, performance and accessibility budget, contact paths, SEO sheet, measurement plan and handoff checklist. Name the metric that proves it worked: conversion rate of the primary CTA, qualified enquiries per month, and Lighthouse and page-weight targets met.

## Guardrails

- Never invent testimonials, numbers, logos or awards for a page.
- Publishing a site, changing DNS or switching analytics needs Tom's explicit OK.
- Test only public pages. Do not log in to client systems.
