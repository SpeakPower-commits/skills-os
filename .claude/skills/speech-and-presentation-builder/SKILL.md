---
name: speech-and-presentation-builder
description: Build a talk, pitch or presentation that persuades, from audience analysis to spoken script, slides, Q&A prep and rehearsal plan, turning data into story. Covers keynotes, funder and investor pitches, workshop sessions, board briefings and webinars. Use for "prepare my talk", "build a pitch", "presentation for", "public speaking through data", "keynote outline", "speaker notes", "Q&A prep", "how should I open", "turn this report into a talk", or when coaching a client on a speech.
metadata:
  domain: comms
  command: campaign
  version: "0.1.0"
---

# Speech and Presentation Builder

Plays the speechwriter and speaking coach behind SpeakPower's "Public Speaking Through Data" line. Produces everything needed to deliver a talk well: the argument, the script, the slides, the hard questions and the practice plan.

## When to use it, and when not

- Use when: Tom or a client has a talk, pitch, workshop or briefing to deliver.
- Do not use when: the job is social content about speaking (use `speakpower-comms-strategist`), a video script (use `video-content-director`), or a document with no live audience (use the `anthropic-skills:docx` skill).

## Inputs

- The audience: who they are, how many, what they already know, and what they will decide.
- The occasion: venue or platform, time slot including questions, language mix, and who speaks before and after.
- The source material: report, data, draft slides, notes.
- The action wanted afterwards.

## Method

1. **Write the one-sentence goal.** "After this talk, [audience] will [do or believe] because [reason]." Everything else serves this sentence.
2. **Plan the time.** Total minutes minus questions, split across no more than three key points. Mark where the talk can lose five minutes if the session runs late.
3. **Choose the structure.** Pitch: problem, evidence, solution, ask. Keynote: story arc with one idea. Workshop: teach, practise, reflect. Briefing: answer first, then the evidence.
4. **Turn data into story.**
   - Pick three to five numbers that carry the argument.
   - One chart carries one message, and its title states the message.
   - Make scale tangible with a comparison the audience knows.
   - Put the source and date on the slide.
   - Check every figure with `data:validate-data` or against the source. Do not invent or round up.
5. **Draft three openings** (a story, a surprising number, a question). Mark one as the **Wildcard** that takes a risk. Recommend one. Write the close: the ask, then one line the audience can repeat.
6. **Write the script for the ear.** Short sentences, plain words, signposts ("three things"), marked pauses and emphasis. Read it aloud; rewrite anything that trips the tongue. Where the audience mixes languages, note where to use a local phrase or switch.
7. **Plan the slides.** One idea per slide, a sentence-style title, minimal words, large type for the back of the room, high contrast. Build with `anthropic-skills:pptx` or Canva. Prepare for failure: a PDF copy, an offline copy, and a version that works with no projector.
8. **Prepare for questions.** List the eight hardest questions, including the hostile one, and write a short, honest answer for each plus a bridge back to the main point. Mark what to say when the answer is "I do not know".
9. **Set the rehearsal plan.** Three rounds: aloud alone, timed with slides, and in front of a critic. Record one run and review pace, filler words and pauses.

## Output

A talk brief, outline with timings, spoken script with delivery marks, slide plan (title and visual per slide), Q&A sheet, cut list, and rehearsal schedule. Name the metric that proves it worked: the action rate after the event (meetings booked, follow-ups, funds committed), one feedback question to the audience, and finishing within time.

## Guardrails

- Never invent statistics, quotes or client results. Use sourced figures only.
- Do not reuse another speaker's material without credit.
- Sending the deck or booking the speaking slot needs Tom's explicit OK.
