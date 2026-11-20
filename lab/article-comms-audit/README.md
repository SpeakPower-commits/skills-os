# Article: "I Audited My Own LinkedIn. It Said I Was Talking to the Wrong People."

Draft, never live. For SpeakPower's LinkedIn (as an article) and blog. About 1,000 words, Tom's voice, written for the target audience (founders and NGO leaders). Service line: Communication Audits. Pillar: Strategy & Market Development.

## Files

| File | What it is |
|---|---|
| `article.md` | The article. The comment block at the top holds the SEO title, meta description, slug and keyword. Alt text sits under each image. |
| `article.html` | Same article with images, for review or pasting into the blog. Rebuild: `src/build-html.ps1`. |
| `linkedin-feed-post.md` | Teaser post for the feed, plus captions for two follow-up image posts. |
| `images/01-hero.png` | Cover, 2400x1254. Use as the LinkedIn article cover and the blog header / social share image. |
| `images/02-audience-gap.png` | Chart, 2400x1350. 29% entry-level vs 6% founders. Also the image for the feed teaser. |
| `images/03-six-checks.png` | The six-check framework, 2400x2400. |
| `images/04-thirty-minute-audit.png` | Shareable 30-minute checklist, 2160x2700 (4:5). Works as a standalone feed post. |
| `i-audited-my-own-linkedin.docx` | Word edition, A4, 6 pages, reader-facing (no SEO block or notes). Cover photo up top, the three graphics in the text, author card with Tom's photo at the end. Built from `article.md`. |
| `i-audited-my-own-linkedin.pdf` | The same document exported to PDF by Microsoft Word. |
| `images/05-cover-photo.jpg` | Human image: banner cropped from `SpeakPower\Graphics & Ads\SpeakPower Ads\SP Ad image.jpg`. |
| `images/06-author-tom.png` | Human image: circular crop of Tom's own photo, `SpeakPower Ads\20250313_152357.jpg`. |
| `src/` | Editable HTML for each graphic and `render.ps1`, which rebuilds the PNGs with headless Edge. Also `prep-photos.ps1` (crops the two photos), `build-docx.js` (Word file), `export-pdf.ps1` (PDF). |

### Rebuilding the Word and PDF files

1. `prep-photos.ps1` crops the two photos into `images/`.
2. `build-docx.js` needs the `docx` package: run `npm install docx --ignore-scripts` in an empty folder, set `NODE_PATH` to that folder's `node_modules`, then `node build-docx.js`.
3. `export-pdf.ps1` must run in 32-bit PowerShell (`%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe`), because 64-bit PowerShell resolves Word automation to WPS Office.

## Check these before it goes live

1. **The numbers.** The follower count is 715, as Tom corrected it on 2026-11-20 (the skills note said 702). The 29% entry-level and 6% founders figures are unchanged and still come from the September 2026 note in `speakpower-comms-strategist`. Confirm them against LinkedIn analytics, and confirm they describe your audience (followers) and not only the people your posts reached. The chart's source line says "page analytics, September 2026".
2. **The story.** The opening says you pointed an audit at yourself in September. If you only looked at the analytics, change "pointed one at myself" so it is literally true.
3. **Posting cadence.** "A seven-days-a-week calendar" comes from the content-ops charter. Change it if you posted less.
4. **Promises made in your name.** You will re-run the check in 90 days and report back, and you invite readers to message you for a second pair of eyes. Both are easy to cut. Say so if you do not want a free-look offer.
5. **The line "Not who hires a strategist"** on the chart, and "A lovely audience, honestly" in the text, describe entry-level followers. Soften them if you worry about how those followers will read them.
6. **No client is named and no client result is claimed.** SCRSDO is left out because there is no outcome to cite yet.

## Design notes

- Palette is taken from your existing SpeakPower ads: navy and gold, with cream for the light graphics. The only logo file is 265px, so it appears small, in a badge.
- The hero is a vector illustration, not a photo. Both image generators were blocked: Higgsfield needs a paid plan and the Canva quota is used up.
- **The cover photo's origin is unknown.** It sits in your ads folder and looks like a stock photo, but I cannot tell whether it is stock or AI-generated. Check the licence or source before publishing, and label it if it is AI-made.
- **Tom's photo** is a casual office snapshot from 13 March 2025. Swap in a proper headshot if you have one: replace `images/06-author-tom.png` and rebuild.
- **Photos I did not use:** `Untitled design (1).jpg` (an identifiable colleague on a private card), the "Empowering Voices" collage (garbled text), and the UBF event photo (a third party). Only two clean human images exist in your SpeakPower folder. More faces need either free stock photos (I would ask before downloading any) or a paid Higgsfield plan or fresh Canva credits.
- The vector hero (`01-hero.png`) is used for LinkedIn and the blog. The Word and PDF editions use the cover photo instead.

## What proves it worked

- **Primary:** the share of founders in the SpeakPower LinkedIn audience. Baseline is 6% (September 2026). Re-read it 90 days after publishing and report it, as the article promises.
- **Leading:** how many founders and NGO leaders message you after the article goes out, counted over the first 14 days.
- **Set a target before publishing.** There is no benchmark here and I have not invented one.

## Wildcard

Run the five-second test on SpeakPower's own homepage in public: film a 60-second clip of a stranger saying what they think SpeakPower does, and post it next to the article. It is the strongest proof the method works, and it only works if you are willing to show a miss.
