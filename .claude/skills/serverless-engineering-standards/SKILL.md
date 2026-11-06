---
name: serverless-engineering-standards
description: Encodes Tom's own coding standards for building browser-only, serverless systems on GitHub Pages, the GitHub Contents API (flat-file JSON datastore), Supabase, and Cloudflare Workers. Always use this skill whenever Tom is building, reviewing, debugging, or extending ANY of his systems — UBF Procurement & Logistics, UBF HR PAR, Tonninyira, CuePointe Action Pool, the Tender Bid Generator/AI-ERP venture, or any new venture — even for a small bug fix or single feature, not just full builds. Also trigger for architecture decisions (flat-file vs. Supabase vs. hybrid), security/credential-exposure reviews, or scaling questions about a flat-file datastore.
metadata:
  domain: engineering
  command: build
  source: claude.ai account
  source-updated: "2026-09-12T05:24:48.282480Z"
  imported: "2026-11-06"
---

# Serverless Engineering Standards

Tom builds and maintains production systems entirely through the browser — no local installs, no desktop dev environment. Every rule here exists because it was learned the hard way on a live UBF or Tonninyira system. Apply them by default; don't wait to be asked.

## Stack Assumptions

- **Data layer, pick one per system's needs:**
  - Pure flat-file: GitHub Contents API storing JSON documents directly in a repo (used by UBF Procurement & Logistics)
  - Hybrid: Supabase for auth (Google OAuth) + relational data, GitHub as archival/document layer (used by UBF HR PAR)
  - Full Supabase: Postgres backend behind a single-file HTML/CSS/JS front end (used by Tonninyira)
- **Compute layer:** Cloudflare Workers for anything needing server-side logic beyond static hosting.
- **Hosting:** GitHub Pages, under Tom's GitHub user account `SpeakPower-commits`. There is no `cuepointe` account on GitHub (checked 2026-11-06).
- **Build constraint:** everything must be buildable and deployable from a browser. Never propose a solution requiring a local CLI, package manager, or IDE unless Tom explicitly says he's working from a different machine.

## Non-Negotiable Rules

1. **Bearer prefix.** GitHub API tokens must be sent as `Authorization: Bearer <token>` — a bare token fails silently in ways that look like a permissions issue.
2. **Re-fetch SHA immediately before every PUT.** The GitHub Contents API requires the current file SHA to write; fetch it fresh right before the write, not earlier in the flow, or concurrent edits produce silent 409 conflicts.
3. **No design drift during bug fixes.** A bug-fix commit touches the bug. It does not also adjust spacing, color, or copy. Flag this explicitly if a fix seems to require a design change, and ask first.
4. **Escape everything written via `innerHTML`.** Every user-supplied or vendor-supplied string rendered into the DOM must be escaped. This has been audited as a strength on the Procurement system — hold every new system to the same bar, don't regress it.
5. **Treat client-side PATs as a standing risk, not a one-off finding.** A GitHub Personal Access Token reachable from browser JS is a repo-write credential exposed to anyone who opens dev tools. Default posture: flag it in any review, and prefer Supabase-issued session tokens or a Worker-side secret for the actual write credential wherever the architecture allows it.
6. **Watch for unbounded repo growth.** Base64-encoded attachments committed directly into git history bloat the repo permanently. Flag any design that stores binary blobs this way; prefer external object storage (Supabase Storage, R2) with the repo holding only a reference.
7. **Mirror official templates exactly when a system's output must match a real-world document** (e.g. HR PAR mirrors the official Excel appraisal template) — don't "improve" the layout unprompted.

## Architecture Decision Heuristic

| If the system needs... | Use |
|---|---|
| Just structured records, low write concurrency, small team | Pure flat-file (GitHub Contents API) |
| Real user accounts / OAuth, moderate concurrency | Hybrid: Supabase auth + GitHub archival |
| Relational queries, ratings/reviews, public-facing scale | Full Supabase |
| Scheduled or externally-triggered server logic | Cloudflare Worker in front of whichever data layer above |

## Code Review Checklist

- [ ] SHA re-fetched immediately before every write path (not cached from an earlier read)
- [ ] Every credential is server-side (Worker secret / Supabase-issued) or explicitly flagged if it isn't
- [ ] Role/state machine logic is centralized, not duplicated inline per page
- [ ] All `innerHTML` writes are escaped
- [ ] No binary blobs committed directly to the repo
- [ ] Bug-fix diffs touch only the bug's code path

## Output Format

Every code deliverable ships with plain-language setup instructions alongside the code — assume Tom will hand this to himself later without full context, not that he needs concept explanations now. State any architecture trade-off directly; don't bury it in caveats.
