---
name: consulting-proposal-and-scope
description: Turn a discovery conversation into a scoped, priced consulting proposal that moves a client from a communications audit into strategy and, if needed, build work. Includes a discovery-call guide, a go or no-go qualification score, scope and deliverables, assumptions and exclusions, three pricing options, timeline, and the follow-up sequence. Use for "write a proposal", "scope this engagement", "price this", "discovery call prep", "quote for a client", "SpeakPower proposal", "follow up after the call", or when a lead asks "how much?".
metadata:
  domain: sales
  command: ""
  version: "0.1.0"
---

# Consulting Proposal and Scope

Plays the engagement manager. Moves a conversation to a signed scope: qualify the lead, run the discovery call, write a proposal the buyer can approve, and follow up without chasing.

## When to use it, and when not

- Use when: a prospect has shown interest, a discovery call is coming, or a client asks for a quote.
- Do not use when: the response is to a formal grant call or tender (use `small-business:grant-rfp-writer`), the document is a legal contract (use `small-business:contract-review` and a lawyer), or the task is finding leads (use `/campaign` and `small-business:lead-finder`).

## Inputs

- Who the prospect is, how they arrived, and what they said they need.
- Notes or a transcript from any conversation so far.
- Tom's rates, currency and payment terms. These are Tom's to set. Use placeholders marked "Tom to set" and never assume them.
- Who decides and how the work will be funded.

## Method

1. **Qualify before investing.** Score 1 to 5 on: problem clarity, access to the decision-maker, budget or funding source, timing, fit with the offer ladder, and risk (scope creep, late payment, reputation). Below an agreed threshold, say so and suggest a smaller entry step or a polite no.
2. **Prepare the discovery call.** Questions: what made this urgent now, what has been tried, what result would count as success and how it would be measured, who decides and who else is involved, the budget range and where it comes from, the deadline, and what happens if nothing changes. Provide a one-page note template to fill during the call.
3. **Shape the offer from the ladder.** Entry: a communications audit with fixed scope. Core: strategy and narrative work. Extension: build and implementation (website, workflows, content system), with coaching as an add-on. Lead with the entry step unless the prospect is already ready for more.
4. **Write the proposal.**
   - Page one: their problem in their own words, the outcome we are aiming for, our approach in three lines, the investment, and the next step.
   - Scope: each deliverable with an acceptance test.
   - Out of scope, assumptions, and what the client must provide and by when.
   - Timeline with milestones and review points.
   - Three options (Essential, Recommended, Extended) with the Recommended one marked.
   - Payment schedule tied to milestones and the payment methods the client uses.
   - Revision limits, confidentiality, ownership of the work, validity date, and how to accept.
5. **Price with logic, not guesswork.** Compute the cost floor from hours and costs, estimate the value to the client, and check against their stated budget. For NGOs, check donor budget rules and any procurement requirements (comparative quotes, registration documents). Do not quote market rates without a retrieved source.
6. **Write the follow-up sequence.** Same day: thanks and a recap. Day 3: one useful insight. Day 7: a check-in. Day 14: close the loop whatever the answer. Draft in Tom's email voice: direct, short, answer first.
7. **Add a Wildcard.** One creative way to lower the buyer's risk, such as a paid pilot, a phased start or a results-linked milestone.

## Output

The qualification score, the discovery-call guide, the proposal draft (produce it with `anthropic-skills:docx`), the follow-up emails as drafts, and the metrics to track: proposals sent, win rate, audit-to-strategy conversion, days from first call to signature, and average deal value.

## Guardrails

- Never invent client references, results or credentials in a proposal.
- Rates, discounts and terms are Tom's decisions. Do not commit to them.
- Never send a proposal or email. Tom approves each one.
- A proposal is not a contract. Contract terms get a legal review before signing.
