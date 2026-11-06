# Routes

Generated from `registry/routes.json` by `os scan`. Edit that file, not this one.

| Command | Use it to | Agent | Start with | Then, if the job calls for it | Tools |
|---|---|---|---|---|---|
| `/think` | Deep strategic analysis | `strategist` | `product-management:brainstorm` | `product-management:product-brainstorming`, `enterprise-search:knowledge-synthesis` | `firecrawl` |
| `/research` | Gather and compare external evidence | `researcher` | `anthropic-skills:deep-research` | `exa:search`, `enterprise-search:search`, `marketing:competitive-brief`, `sales:competitive-intelligence`, `design:user-research` | `firecrawl`, `apify`, `composio` |
| `/analyze` | Inspect project data | `analyst` | `data:analyze` | `data:explore-data`, `data:validate-data`, `data:statistical-analysis`, `data:write-query`, `anthropic-skills:xlsx` | `apify`, `composio` |
| `/build` | Plan or implement a software solution | `engineer` | `serverless-engineering-standards` | `engineering:system-design`, `engineering:architecture`, `engineering:testing-strategy`, `engineering:debug`, `engineering:deploy-checklist`, `anthropic-skills:mcp-builder` | `playwright`, `chrome-devtools`, `browser` |
| `/campaign` | Develop a market or brand campaign | `comms-director` | `social-media-manager` | `ubf-comms-strategist`, `speakpower-comms-strategist`, `video-content-director`, `marketing:campaign-plan`, `marketing:email-sequence`, `brand-voice:enforce-voice`, `postiz:postiz` | `higgsfield`, `canva`, `composio` |
| `/audit` | Find weaknesses, risks or missed opportunities | `auditor` | `operations:risk-assessment` | `code-review`, `security-review`, `engineering:tech-debt`, `searchfit-seo:seo-audit`, `searchfit-seo:ai-visibility`, `design:accessibility-review`, `small-business:contract-review` | `chrome-devtools`, `firecrawl`, `playwright` |
| `/measure` | Review KPIs and outcomes | `analyst` | `product-management:metrics-review` | `marketing:performance-report`, `data:build-dashboard`, `operations:status-report`, `small-business:business-pulse` | `composio`, `apify` |
| `/decide` | Compare options and recommend one | `strategist` | `operations:risk-assessment` | `operations:vendor-review`, `operations:change-request` | `firecrawl` |
| `/learn` | Store validated lessons and decisions | `librarian` | `productivity:memory-management` | `anthropic-skills:consolidate-memory`, `anthropic-skills:skill-creator` |  |
| `/portfolio` | Look across projects for cross-project opportunities | `strategist` | `enterprise-search:knowledge-synthesis` | `enterprise-search:digest`, `operations:capacity-plan` |  |
| `/inbox` | Turn email into decisions, drafts and handoffs | `chief-of-staff` | `inbox-triage` | `small-business:inbox-manager`, `sales:inbox-sweep`, `sales:lead-triage`, `customer-support:ticket-triage` | `gmail`, `composio` |

## When two skills share a name, use this one

- **call-prep**: `sales:call-prep`. Provisional. Use the hubspot-sales one only when the account lives in HubSpot.
- **competitive-brief**: `marketing:competitive-brief`. Provisional. Use the product-management one for product decisions.
- **content-strategy**: `searchfit-seo:content-strategy`. Provisional. Dedicated SEO toolkit.
- **lead-triage**: `sales:lead-triage`. Provisional.
- **search**: `enterprise-search:search`. Provisional. For your connected tools; exa:search is for the open web and needs sign-in.
- **seo-audit**: `searchfit-seo:seo-audit`. Provisional. Dedicated SEO toolkit that works on any site or codebase.
- **start**: `productivity:start`. Provisional. Use zoom-plugin:start only for Zoom integration work.
