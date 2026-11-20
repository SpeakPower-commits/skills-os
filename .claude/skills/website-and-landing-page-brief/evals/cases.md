# Test cases for website-and-landing-page-brief

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "Brief a landing page whose only goal is to book a communications audit call." Expected: one primary conversion, visitor questions, a no-navigation outline, three hero options including a Wildcard, a WhatsApp click-to-chat path, a mobile performance budget and a measurement plan.
2. "Redo the homepage for a refugee-led community organisation." Expected: the NGO structure with verified impact figures only, governance and contact sections, consent and privacy attention, and no invented numbers.
3. "Will my site get found?" Expected: a findability plan covering titles, structured data, Google Business Profile and AI-search readiness, pointing to `searchfit-seo` skills for detail.

## Should not trigger

1. "Crawl my site and list every SEO error." Expected: routes to `searchfit-seo:seo-audit`.
2. "Build the Supabase backend for the booking form." Expected: routes to `/build` with `serverless-engineering-standards`.
