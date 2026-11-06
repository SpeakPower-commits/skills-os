# Tools

Generated from `registry/tools.json` by `os scan`; status is as of the last scan. Before relying on a tool, confirm its tools are loaded in your session. If they are not, say so and use the fallback.

| Tool | Use it for | Not for | If unavailable | Status | Used by |
|---|---|---|---|---|---|
| `apify` | Scraping at scale: thousands of ready-made scrapers (Actors) for Google Maps, social media, e-commerce, search results and directories. Lead lists... | One page or one small site; use firecrawl | firecrawl, or composio's web tools | set up; sign in on first use | /research, /analyze, /measure |
| `firecrawl` | Turning websites into clean markdown or structured JSON: scrape a page, map or crawl a site, search the web and read the results, extract fields. | Platforms that need a logged-in browser; use playwright. Bulk platform scraping; use apify | the built-in browser for single pages | set up; sign in on first use | /think, /research, /audit, /decide |
| `composio` | Acting in 250+ apps: Gmail, Outlook, Calendar, Sheets, Drive, Notion, Slack, HubSpot, LinkedIn, Instagram and more. Always search its tools first... | Apps that have their own connector here (Gmail, Canva); prefer those | the app's own connector, or ask Tom to paste the data | claude.ai connector | /research, /analyze, /campaign, /measure, /inbox |
| `chrome-devtools` | Diagnosing a web page in real Chrome: console errors, network requests, performance traces, screenshots. Use it to find why a site is slow or broken. | Long scripted flows across many pages; use playwright | the built-in browser (console and network reading) | set up, but needs node to run | /build, /audit |
| `playwright` | Driving a browser step by step: multi-page flows, form filling, testing a web app end to end, capturing pages that need clicks or scrolling. | Reading a public page; use firecrawl. Diagnosing performance; use chrome-devtools | the built-in browser | set up, but needs node to run | /build, /audit |
| `higgsfield` | Generating images and short videos for campaigns, ads, social posts and video scenes. | Layouts with text, brand templates or carousels; use canva | canva, or a written brief for a designer | set up; sign in on first use | /campaign |
| `gmail` | Reading, searching, labelling and drafting in Tom's Gmail. The first choice for /inbox. | Other mailboxes; use composio (Outlook) or pasted text | composio Gmail, or pasted email text | claude.ai connector | /inbox |
| `canva` | Designs with layout and text: social graphics, carousels, posters, one-pagers, decks, brand templates. | Photoreal images or video generation; use higgsfield | a written design brief | claude.ai connector | /campaign |
| `browser` | The Claude app's built-in browser: open pages, click, fill, read console and network. Needs no install, so it backs up playwright and chrome-devtools. | Large scraping jobs; use apify or firecrawl | firecrawl for reading | built into the Claude app | /build |

Sign-in, costs and approval rules for each tool are in `registry/tools.json`. Live status: `os.cmd tools`.
