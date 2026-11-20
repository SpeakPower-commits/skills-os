// Builds monthly-rolex-festival-proposal-and-plan.docx (A4).
// Needs the `docx` package: npm install docx --ignore-scripts in an empty folder,
// then run with NODE_PATH pointing at that folder's node_modules.
//   set NODE_PATH=<folder>\node_modules
//   node build-docx.js [output.docx]
//
// Inline markup inside any text: **bold**  and  [[yellow highlight = still to confirm]].

const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, WidthType, ShadingType,
  BorderStyle, AlignmentType, LevelFormat, HeadingLevel, Footer, PageNumber, VerticalAlign,
  TabStopType,
} = require("docx");

const OUT = process.argv[2] || path.join(__dirname, "..", "monthly-rolex-festival-proposal-and-plan.docx");

// ---------- look ----------
const FONT = "Calibri";
const BRAND = "7C2D12";   // deep rust, header rows and headings
const BAND = "FFF7ED";    // light cream, alternate rows
const PHASE = "FDE3B4";   // warm sand, phase rows
const LABEL = "F5EBDD";   // label column
const GREY = "57534E";
const W = 9638;           // A4 with 2 cm margins, in DXA

const line = { style: BorderStyle.SINGLE, size: 4, color: "D6D3D1" };
const borders = { top: line, bottom: line, left: line, right: line };

// ---------- helpers ----------
function runs(text, base = {}) {
  const out = [];
  const re = /(\*\*[^*]+\*\*|\[\[[^\]]+\]\])/g;
  let last = 0, m;
  while ((m = re.exec(text))) {
    if (m.index > last) out.push(new TextRun({ ...base, text: text.slice(last, m.index) }));
    const t = m[0];
    if (t.startsWith("**")) out.push(new TextRun({ ...base, text: t.slice(2, -2), bold: true }));
    else out.push(new TextRun({ ...base, text: t.slice(2, -2), highlight: "yellow" }));
    last = m.index + t.length;
  }
  if (last < text.length) out.push(new TextRun({ ...base, text: text.slice(last) }));
  return out;
}

const P = (text, o = {}) => new Paragraph({
  spacing: { before: o.before ?? 0, after: o.after ?? 120, line: 276 },
  alignment: o.align,
  keepNext: o.keepNext,
  children: runs(text, { size: o.size ?? 22, color: o.color, bold: o.bold, italics: o.italics }),
});
const H1 = (text, pageBreak = false) => new Paragraph({ heading: HeadingLevel.HEADING_1, pageBreakBefore: pageBreak, children: [new TextRun(text)] });
const H2 = (text) => new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(text)] });
const Bullet = (text) => new Paragraph({
  numbering: { reference: "bullets", level: 0 },
  spacing: { before: 0, after: 80, line: 276 },
  children: runs(text, { size: 22 }),
});
const gap = (after = 160) => new Paragraph({ spacing: { before: 0, after, line: 120 }, children: [] });

function cell(content, width, o = {}) {
  const items = Array.isArray(content) ? content : [content];
  return new TableCell({
    width: { size: width, type: WidthType.DXA },
    columnSpan: o.span,
    borders,
    shading: o.fill ? { type: ShadingType.CLEAR, fill: o.fill, color: "auto" } : undefined,
    margins: { top: 60, bottom: 60, left: 110, right: 110 },
    verticalAlign: VerticalAlign.TOP,
    children: items.map((t) => new Paragraph({
      alignment: o.align,
      keepNext: o.keepNext,
      spacing: { before: 0, after: 40, line: 250 },
      children: runs(String(t), { size: o.size ?? 20, bold: o.bold, color: o.color }),
    })),
  });
}

// rows: array of  string[]  |  {phase:"text"}  |  {cells:string[], bold:true, fill:"HEX"}
// opts.label = first column is a shaded label column
function table(widths, header, rows, opts = {}) {
  const total = widths.reduce((a, b) => a + b, 0);
  const out = [];
  if (header) {
    out.push(new TableRow({
      tableHeader: true, cantSplit: true,
      children: header.map((h, i) => cell(h, widths[i], { fill: BRAND, color: "FFFFFF", bold: true })),
    }));
  }
  let n = 0;
  for (const r of rows) {
    if (r.phase) {
      out.push(new TableRow({ cantSplit: true, children: [cell(r.phase, total, { fill: PHASE, bold: true, span: widths.length, keepNext: true })] }));
      n = 0;
      continue;
    }
    const plain = Array.isArray(r);   // note: arrays have a built-in .fill method, so do not read r.fill on them
    const cells = plain ? r : r.cells;
    const fillRow = (!plain && r.fill) || (n % 2 ? BAND : undefined);
    out.push(new TableRow({
      cantSplit: true,
      children: cells.map((c, i) => cell(c, widths[i], {
        fill: opts.label && i === 0 ? LABEL : fillRow,
        bold: (!plain && r.bold) || (opts.label && i === 0),
        align: opts.rightCols && opts.rightCols.includes(i) ? AlignmentType.RIGHT : undefined,
      })),
    }));
    n++;
  }
  return new Table({ width: { size: total, type: WidthType.DXA }, columnWidths: widths, rows: out });
}

const note = (text) => P(text, { size: 19, color: GREY, italics: true, before: 60, after: 160 });

// ---------- content ----------
const kids = [];
const add = (...x) => kids.push(...x);

// Title block
add(
  new Paragraph({ spacing: { before: 0, after: 40 }, children: [new TextRun({ text: "Monthly Rolex Festival", font: FONT, size: 56, bold: true, color: BRAND })] }),
  new Paragraph({
    spacing: { before: 0, after: 100 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: BRAND, space: 6 } },
    children: [new TextRun({ text: "Proposal and plan", font: FONT, size: 34, color: GREY })],
  }),
  P("Draft for the festival team. Prepared 20 November 2026.", { size: 20, color: GREY, after: 80 }),
  P("**How to read this:** [[Yellow]] means we still have to confirm it. A box (☐) is for ticking when the job is done. UGX means Ugandan shillings.", { size: 20, after: 80 }),
  P("**What we assumed:** the festival is a food festival built around the Rolex, because that is what the research shared with us covers. The venue is in Kampala, so Kampala Capital City Authority (KCCA) rules apply. Prices and costs are the research figures until we test them ourselves.", { size: 20, after: 120 }),
);

// 1
add(H1("1. The proposal at a glance"));
add(table([2300, 7338], null, [
  ["What it is", "A monthly street-food festival built around the Rolex (the egg-and-chapati wrap). Four Rolexes on the menu, sold singly and as combos, all with one house sauce."],
  ["Why it can work", "Everyone already knows Rolex, so we do not have to explain it. A fixed monthly date gives people a reason to come back, and lets us improve prices and the menu a little every month."],
  ["Who it is for", "Street customers and students (small combo), families and takeaway or delivery (full combo), people who want a sit-down treat (premium combo). [[Confirm the main audience.]]"],
  ["When and where", "Every month. First festival: [[date to confirm]] at [[venue to confirm]]."],
  ["The menu", "Chicken Rolex, Beef Rolex, Sausage Rolex, Spicy Vegetable Rolex. One house sauce, yogurt based, no mayo. A combo with one of each."],
  ["Starting price", "Full Combo (one of each of the four): **UGX 35,000**, which is UGX 8,750 per Rolex. Mini and Premium combos are in Section 3."],
  ["The money in one line", "If one Rolex costs UGX 5,000 to 6,000 to make, a Full Combo costs UGX 20,000 to 24,000 and earns UGX 11,000 to 15,000 before festival costs. [[The cost per Rolex is not tested yet.]]"],
  ["What comes first", "Decide the date, venue and budget (Section 2). Run a test batch to learn our true cost (Section 5). Send KCCA our application at least 14 working days before the date (Section 8)."],
  ["How we will know it worked", "**Net profit per festival:** sales, minus food cost, minus festival costs. Festival 1 must at least break even. From festival 2 it must make a profit and grow (Section 10)."],
], { label: true }));
add(gap());

// 2
add(H1("2. Decisions we need first"));
add(P("Nothing in the research tells us these. Until they are settled, the plan cannot be fixed.", { keepNext: true }));
add(table([600, 3900, 5138], ["#", "Decision", "Why it matters"], [
  ["1", "Is this a Rolex-led food festival, as we assumed?", "The menu, the budget and the permits all follow from this."],
  ["2", "Date and venue for festival 1", "KCCA needs the venue owner's clearance and 14 working days' notice. The date sets every deadline in Section 5."],
  ["3", "How many people do we expect at festival 1?", "It decides how much food to buy and how many helpers we need. A sensible first target is about 100 combos."],
  ["4", "Total budget, and where the money comes from", "Section 4 shows profit per combo, not what the whole festival costs. We need the real total to find the break-even point."],
  ["5", "Who holds each role", "Every job needs one named owner (Section 7)."],
  ["6", "Do we sell single Rolexes as well as combos, and at what price?", "The research only gives combo prices. A single must cost more than UGX 8,750, the per-Rolex price inside the Full Combo, or nobody will buy the combo."],
  ["7", "Only us, or other food sellers too?", "More sellers bring a bigger crowd, but each one needs a licence and health certificate (Section 8)."],
  ["8", "Free entry or tickets?", "Ticket money is not in any number in this plan yet."],
]));
add(gap());

// 3
add(H1("3. What we are selling"));
add(P("**Every Rolex starts the same:** 1 chapati, 2 eggs beaten with salt, 1 handful of shredded cabbage, 2 spoons of house sauce. What changes is the filling.", { keepNext: true }));
add(table([1900, 4500, 3238], ["Rolex", "Filling", "What makes it different"], [
  ["Chicken", "½ cup cooked chicken strips, grilled or fried with salt, black pepper and garlic.", "Light sauce, so the chicken is not overpowered."],
  ["Beef", "½ cup beef strips fried with onions, garlic, salt and Royco or black pepper until soft, plus green pepper.", "A little extra lemon. Garlic and pepper make the beef taste rich."],
  ["Sausage", "1 to 2 sausages sliced lengthways and fried brown, plus onions and tomatoes.", "Extra chilli if wanted. The sweet-tangy sauce suits sausage."],
  ["Spicy Vegetable", "Cabbage, grated carrot, green pepper, onion, tomato and 2 to 3 chopped pilipili, fried 2 minutes with salt and garlic until soft but still crunchy.", "Extra chilli in the sauce. The meat-free choice."],
]));
add(gap(80));
add(H2("Combos and prices"));
add(table([1500, 3000, 2300, 2838], ["Combo", "What is in it", "Price in the research (UGX)", "Our check: price per Rolex (UGX)"], [
  ["Mini", "Half of each Rolex, which is 2 full Rolexes of food", "20,000 to 25,000", "10,000 to 12,500"],
  ["Full", "One full Rolex of each type, 4 Rolexes", "35,000 to 40,000", "8,750 to 10,000"],
  ["Premium", "The Full Combo plus chips and a soda", "45,000 to 50,000", "11,250 to 12,500, with chips and soda included"],
]));
add(note("The research advises starting with the Full Combo at UGX 35,000 so customers feel they are saving. Our check found one thing to decide: the Mini costs more per Rolex than the Full Combo. That is fine if it is a deliberate tasting price, but we should choose it on purpose."));
add(P("[[Decision: keep the Mini at UGX 20,000 to 25,000, or lower it?]]", { after: 160 }));
add(H2("What other sellers charge (from the research, not yet checked)"));
add(table([4200, 3400, 2038], ["Where", "Item", "Price quoted (UGX)"], [
  ["A Rolex parlour in Kampala", "Chicken Rolex", "14,000"],
  ["A Rolex parlour in Kampala", "Beef Rolex", "15,000"],
  ["A Rolex parlour in Kampala", "Spicy chicken Rolex", "16,000"],
  ["A Rolex parlour in Kampala", "Vegetable Rolex", "10,000"],
  ["Glovo, Kampala", "Beef Rolex", "11,500"],
  ["A restaurant", "Beef or chicken Rolex", "20,000"],
], { rightCols: [2] }));
add(note("These numbers must be checked by visiting sellers (Section 5, step 3). See Appendix C."));

// 4
add(H1("4. The budget line"));
add(P("The research gives one cost figure: about UGX 5,000 to 6,000 to make one Rolex. Everything below is built from that, with the arithmetic shown, so it can be replaced as soon as our test run gives real numbers.", { keepNext: true }));
add(H2("4a. What one Full Combo earns"));
add(table([4800, 2419, 2419], ["", "Worse case", "Better case"], [
  ["Cost to make one Rolex (research figure)", "6,000", "5,000"],
  ["Cost of one Full Combo (4 Rolexes)", "24,000", "20,000"],
  ["Selling price of one Full Combo", "35,000", "35,000"],
  { cells: ["Profit per combo, before festival costs", "11,000", "15,000"], bold: true, fill: PHASE },
  ["Profit as a share of the price", "31%", "43%"],
], { rightCols: [1, 2] }));
add(gap(100));
add(H2("4b. How many combos pay for the festival"));
add(P("**Combos to sell to break even = total festival costs ÷ profit per combo.** The festival costs below are only examples. Put our real total from 4d into the rule.", { keepNext: true }));
add(table([3600, 3019, 3019], ["If festival costs are (UGX)", "Combos to sell, worse case", "Combos to sell, better case"], [
  ["1,000,000", "91", "67"],
  ["2,000,000", "182", "134"],
  ["3,000,000", "273", "200"],
  ["5,000,000", "455", "334"],
], { rightCols: [0, 1, 2] }));
add(gap(100));
add(H2("4c. What different sales look like"));
add(table([1700, 2300, 2900, 2738], ["Combos sold", "Sales (UGX)", "Food cost (UGX)", "Profit before festival costs (UGX)"], [
  ["50", "1,750,000", "1,000,000 to 1,200,000", "550,000 to 750,000"],
  ["100", "3,500,000", "2,000,000 to 2,400,000", "1,100,000 to 1,500,000"],
  ["200", "7,000,000", "4,000,000 to 4,800,000", "2,200,000 to 3,000,000"],
  ["400", "14,000,000", "8,000,000 to 9,600,000", "4,400,000 to 6,000,000"],
], { rightCols: [0, 1] }));
add(note("This assumes every sale is a Full Combo at UGX 35,000. Real sales will mix single Rolexes and combos, so the figures will move."));
add(H2("4d. Our festival cost lines (to fill in)"));
add(P("These lines follow what KCCA asks every event to provide (Section 8), plus the food stall itself. The total goes into the break-even rule in 4b.", { keepNext: true }));
add(table([2500, 4238, 1600, 1300], ["Cost line", "What it covers", "Amount (UGX)", "Quote from"], [
  ["Food and packaging", "Ingredients and foil or paper wrap (Appendix B)", "[[from test run]]", "Food lead"],
  ["Venue", "Hire, or the fee paid to the venue owner", "[[to quote]]", "Logistics"],
  ["KCCA application", "Any fee for the event application", "[[ask KCCA]]", "Logistics"],
  ["Police and security", "Police presence at the venue, and guards if needed", "[[to quote]]", "Logistics"],
  ["Fire safety", "Extinguishers, fire safety blankets, marked exits", "[[to quote]]", "Logistics"],
  ["First aid", "First aid kit and a person who knows how to use it", "[[to quote]]", "Logistics"],
  ["Toilets, water and bins", "Marked toilets for men and women that people with disabilities can use, water supply, litter bins, waste removal", "[[to quote]]", "Logistics"],
  ["Power and lighting", "Mains or generator, lights inside and outside", "[[to quote]]", "Logistics"],
  ["Cooking equipment", "Gas or charcoal, pans or hot plates, cool boxes, tables, shade, hand-washing station", "[[to quote]]", "Food lead"],
  ["Helpers", "Cooks, servers, cashier, cleaners (pay or meals)", "[[to agree]]", "Treasurer"],
  ["Marketing", "Posters, printing, any paid promotion", "[[to quote]]", "Marketing"],
  ["Sound and music", "Speakers, and a music licence if one is needed", "[[to quote]]", "Logistics"],
  ["Reserve", "Our suggestion: keep about 10% of the total aside for surprises", "[[10% of total]]", "Treasurer"],
  { cells: ["Total festival costs", "Add the lines above. This is the number for 4b.", "[[total]]", ""], bold: true, fill: PHASE },
]));
add(gap());

// 5
add(H1("5. What needs to be done"));
add(P("**W-10** means ten weeks before the festival. **W0** is festival day. The timings are our suggestion. The one fixed rule is KCCA's: apply at least 14 working days before the event. We aim to apply at W-6, so there is time to fix anything KCCA sends back and still promote for three weeks.", { keepNext: true }));
add(table([500, 5000, 1700, 1500, 938], ["#", "What to do", "Who", "By when", "Done"], [
  { phase: "Phase 1. Decide (W-10 to W-9)" },
  ["1", "Confirm the festival name, date, venue and expected crowd (Section 2).", "Festival lead", "W-10", "☐"],
  ["2", "Agree the total budget, where festival money is kept, and who may spend it.", "Treasurer", "W-10", "☐"],
  ["3", "Visit 5 Rolex sellers. Write down their prices, portion sizes and what goes in each. Compare with the research figures.", "Food lead", "W-9", "☐"],
  ["4", "Name one owner for every role in Section 7.", "Festival lead", "W-9", "☐"],
  { phase: "Phase 2. Venue and permits (W-9 to W-6)" },
  ["5", "Get the venue owner's written clearance. A receipt showing we paid is accepted.", "Logistics lead", "W-8", "☐"],
  ["6", "Get a police letter clearing the venue, and arrange police presence. Ask the police if a Public Order Management Act notice also applies (Section 8).", "Logistics lead", "W-8", "☐"],
  ["7", "Write the plans KCCA asks for: fire, crowd flow, first aid, toilets, waste, noise, power, water.", "Logistics lead", "W-7", "☐"],
  ["8", "Confirm with KCCA which licence and health certificate each food seller must hold, and collect copies.", "Food lead", "W-7", "☐"],
  ["9", "Send KCCA the formal letter with every attachment. KCCA's rule is at least 14 working days before the date. We aim for W-6.", "Festival lead", "W-6", "☐"],
  { phase: "Phase 3. Test and prepare (W-6 to W-1)" },
  ["10", "Test run: make 10 of each Rolex. Time every one, record every ingredient, and taste-test with 10 people.", "Food lead", "W-5", "☐"],
  ["11", "Work out the true cost of one Rolex from the test run. Set prices from it (Section 4).", "Treasurer", "W-4", "☐"],
  ["12", "Fill in Appendix B with real prices. Order dry goods, gas or charcoal, and equipment.", "Food lead", "W-2", "☐"],
  ["13", "Recruit and brief the helpers. Rehearse the serving line once.", "Festival lead", "W-2 to W-1", "☐"],
  ["14", "Book tents or shade, tables, cool boxes, hand-washing stations, bins, toilets, lights, power.", "Logistics lead", "W-2", "☐"],
  { phase: "Phase 4. Promote (W-3 to W0), once KCCA has confirmed" },
  ["15", "Announce the date, place, menu and combo price on posters, WhatsApp groups and social media. Remind people every week.", "Marketing lead", "W-3 to W0", "☐"],
  { phase: "Phase 5. Festival day (W0)" },
  ["16", "Set up 3 hours before opening: stalls, hand-washing, cool boxes for the sauce, bins, signs, first aid, clear exits.", "Logistics lead", "W0, early", "☐"],
  ["17", "Cook in small batches. Spread the sauce when serving. Wrap tight in foil or paper.", "Food lead", "W0, open", "☐"],
  ["18", "Record every sale by product. Count cash and mobile money at set times, two people together.", "Treasurer", "W0, all day", "☐"],
  ["19", "Close: clean up, remove all waste, count leftover stock.", "Everyone", "W0, close", "☐"],
  { phase: "Phase 6. After (within one week)" },
  ["20", "Count sales, costs and profit. Compare with the targets in Section 10.", "Treasurer", "Within 3 days", "☐"],
  ["21", "Collect customer feedback: what sold out, what did not, how long the queue was.", "Front of house", "Within 3 days", "☐"],
  ["22", "Decide three changes. Thank the sellers and helpers. Set the next date and start the next KCCA application straight away.", "Festival lead", "Within 1 week", "☐"],
]));
add(gap());

// 6
add(H1("6. Do and don't"));
add(table([1700, 4069, 3869], ["Topic", "Do", "Don't"], [
  ["Permits and venue", "Apply to KCCA at least 14 working days before the festival, with every attachment. Keep copies.", "Don't announce a final date until the venue and KCCA are confirmed."],
  ["Prices and costs", "Cost every Rolex in the test run. Set prices from our own numbers. Re-check before every festival.", "Don't treat the research prices or the UGX 5,000 to 6,000 cost as final. Don't price a combo below its cost."],
  ["Food safety", "Keep the sauce in a cool box. Make small batches. Cook eggs and meat all the way through. Wash hands. Use only licensed, certified food sellers.", "Don't leave sauce, eggs or cooked meat standing in the heat. Don't use the same board or knife for raw meat and vegetables."],
  ["Serving", "Spread the sauce on the chapati when serving, so it stays fresh. Wrap tight in foil or paper.", "Don't build the day's Rolexes in advance. The chapati goes soggy."],
  ["Money", "Count cash and mobile money with two people. Log every sale by product.", "Don't spend festival money without the Treasurer recording it. Don't let one person handle cash alone."],
  ["Crowd and neighbours", "Plan entry and exit, bins, toilets, water, lighting and first aid. Keep noise at 60 decibels.", "Don't let water, light or bins run out. Don't block a fire exit."],
  ["Team", "Give every job one named owner. Brief everyone before the day.", "Don't start without a Food lead and a Treasurer. Don't change the menu on festival day."],
  ["After the festival", "Count results within 3 days. Decide three changes for next month.", "Don't skip the count. Don't leave the next KCCA application until late."],
]));
add(gap());

// 7
add(H1("7. Who does what"));
add(table([2000, 5400, 2238], ["Role", "Main job", "Name"], [
  ["Festival lead", "Owns the plan and the date. Signs the KCCA letter. Makes the final call when the team is split.", "[[to assign]]"],
  ["Treasurer", "Holds the budget, pays the bills, records every shilling, runs the count after the festival.", "[[to assign]]"],
  ["Food lead", "Recipes, the test run, buying, cooking and cleanliness. Makes sure every food seller is licensed and certified.", "[[to assign]]"],
  ["Front of house", "The till, the queue, serving customers, collecting feedback.", "[[to assign]]"],
  ["Logistics lead", "Venue, police, the plans KCCA asks for, power, water, toilets, bins, equipment.", "[[to assign]]"],
  ["Marketing lead", "Poster, WhatsApp and social media posts, photos, weekly reminders.", "[[to assign]]"],
  ["Helpers", "Cooks, servers, cleaners. Briefed before the day.", "[[to recruit]]"],
]));
add(note("At the start one person may hold two roles. Never leave a role without a name."));

// 8
add(H1("8. Permits and rules in Kampala"));
add(P("This is KCCA's own checklist for anyone applying to hold an event, set out in plain words. Source: KCCA Events checklist, kcca.go.ug/uploads/KCCA_Events_checklist.pdf, read on 20 November 2026.", { keepNext: true }));
add(table([500, 2900, 5238, 1000], ["#", "KCCA asks for", "In plain words", "Done"], [
  ["1", "A formal letter requesting to hold the event", "A letter to KCCA asking permission. We suggest it gives the name, date, place, hours and expected crowd.", "☐"],
  ["2", "Security and police", "A police letter clearing the venue as suitable for an event, and police officers at the venue on the day.", "☐"],
  ["3", "Clearance from the venue owner", "The owner's permission to hold the event. A receipt showing we paid can be accepted.", "☐"],
  ["4", "Fire control", "Fire extinguishers, fire safety blankets and fire exits. We are cooking, so this matters most at our stalls.", "☐"],
  ["5", "Crowd flow and control", "Entry and exit points, fencing at public access points, and emergency assembly points.", "☐"],
  ["6", "First aid", "First aid facilities at the venue.", "☐"],
  ["7", "Toilets", "Clearly marked for men and women, and usable by infants and people with disabilities.", "☐"],
  ["8", "Waste", "A plan for rubbish, with litter bins.", "☐"],
  ["9", "Noise", "Keep noise at 60 decibels.", "☐"],
  ["10", "Power", "Lighting inside and outside.", "☐"],
  ["11", "Water", "Water guaranteed for the whole event.", "☐"],
  ["12", "Food vending", "Only licensed and certified food sellers, for the whole event.", "☐"],
  ["13", "Timing", "Apply 14 working days before the event date.", "☐"],
]));
add(gap(100));
add(H2("Also ask about (not on KCCA's list)"));
add(Bullet("**Police notice under the Public Order Management Act 2013.** The Act asks for written notice to the police 3 to 15 days before a \"public meeting\". The Act defines that as a gathering to discuss or express views on a matter of public interest, so a food festival may not count. Ask the police and keep their answer in writing."));
add(Bullet("**Music licence.** If we play or perform music, ask the Uganda Performing Rights Society whether we need a licence. [[Not checked.]]"));
add(Bullet("**Tax and registration.** Ask the Uganda Revenue Authority or an accountant what applies to festival sales. [[Not checked.]]"));
add(Bullet("**A venue outside Kampala.** KCCA covers Kampala. Anywhere else, ask the local authority for its own list."));
add(gap(80));

// 9
add(H1("9. Risks"));
add(table([1900, 3700, 4038], ["Risk", "What could go wrong", "What we do about it"], [
  ["Food illness", "Yogurt sauce, eggs and meat spoil in the heat. The research says the sauce lasts only 2 to 3 days, in a fridge.", "Keep sauce in a cool box with ice. Small batches. Cook through. Hand-washing station. Certified food sellers only."],
  ["Costs go up", "In 2023 a packet of wheat flour rose from about UGX 5,500 to 7,500, and cooking oil was double its 2021 price (Africanews, July 2023).", "Re-cost before every festival. Buy dry goods early. Review prices each month."],
  ["The research figures are wrong", "The market prices and the UGX 5,000 to 6,000 cost are unchecked. In 2023 a street Rolex was reported at under one US dollar (Christian Science Monitor).", "Visit sellers and run the test before fixing any price."],
  ["Too few customers", "Unsold food and unpaid costs.", "Start with about 100 combos. Promote from W-3. Make break-even the goal of festival 1."],
  ["Long queues", "Slow service loses customers.", "Time each Rolex in the test run. One station per Rolex type. Pre-cook the fillings. Sauce goes on at serving."],
  ["Rain or power cuts", "Cooking stops.", "Shade or covered stalls, spare gas or charcoal, a wet-weather plan."],
  ["Permit delay", "No approval, no festival.", "Apply at W-6. Announce only after KCCA confirms."],
  ["Money goes missing", "Cash handled by one person.", "Two-person counts. Mobile money where possible. A record of every sale."],
]));
add(gap());

// 10
add(H1("10. How we will know it worked"));
add(table([2300, 3800, 3538], ["Measure", "How we count it", "Target"], [
  ["**Net profit (the main one)**", "Sales, minus food cost, minus all festival costs.", "Festival 1: at least break even. Festival 2 onwards: profit, and growing. [[Set the number once the budget is fixed.]]"],
  ["Combos sold", "Till record, by combo type.", "At least the break-even number from Section 4b."],
  ["Real cost of one Rolex", "Total on the Appendix B list, divided by the number of Rolexes made.", "At or under the UGX 6,000 we assumed."],
  ["Queue time", "Minutes from joining the line to holding food.", "[[Suggested: under 10 minutes.]]"],
  ["Repeat customers", "Ask at the till: \"Been before?\"", "A higher share each month."],
  ["Sell-outs and leftovers", "Count what ran out and what was left.", "Less left over each month, without running out early."],
  ["Food safety complaints", "Anyone who tells us they were sick.", "Zero."],
]));
add(gap());

// 11
add(H1("11. Wildcard"));
add(new Table({
  width: { size: W, type: WidthType.DXA }, columnWidths: [W],
  rows: [new TableRow({ cantSplit: true, children: [new TableCell({
    width: { size: W, type: WidthType.DXA }, borders,
    shading: { type: ShadingType.CLEAR, fill: BAND, color: "auto" },
    margins: { top: 120, bottom: 100, left: 160, right: 160 },
    children: [
      P("**Optional, and riskier: the Rolex Battle.**", { size: 21, after: 80 }),
      P("Invite 3 to 5 local Rolex sellers to compete at the festival. Customers vote with tokens. The winner's Rolex goes on our menu as the Rolex of the Month.", { size: 21, after: 80 }),
      P("**Why it might work:** the sellers bring their own customers, so the crowd grows without us paying for more promotion, and voting gives people a reason to come back.", { size: 21, after: 80 }),
      P("**The risk:** every extra seller needs a licence and a health certificate, and we share the crowd.", { size: 21, after: 80 }),
      P("**How we would know:** tokens cast, new visitors (ask at the till), and whether our sales per visitor hold up.", { size: 21, after: 0 }),
    ],
  })] })],
}));

// Appendix A
add(H1("Appendix A. Recipes", true));
add(P("From the research shared with us. Nothing here has been tasted or tested by us yet.", { keepNext: true }));
add(H2("The house sauce (no mayo)"));
add(table([4000, 5638], ["Ingredient", "Amount"], [
  ["Plain yogurt or mala", "1 cup. Thick is best."],
  ["Tomato ketchup", "2 spoons"],
  ["Cooking oil", "1 spoon"],
  ["Garlic", "1 small, crushed"],
  ["Lemon", "½, squeezed"],
  ["Sugar", "½ spoon"],
  ["Salt and black pepper", "A pinch of each"],
  ["Chilli (pilipili)", "As much as you like"],
]));
add(note("Put everything in a bowl and whisk until smooth. Taste: more lemon for tang, more chilli for heat. Keep in the fridge, 2 to 3 days. Our estimate: one batch covers about 10 Rolexes if a spoon means a tablespoon. Check this in the test run."));
add(H2("How to make each Rolex"));
add(table([1900, 7738], ["Rolex", "Method (fillings are in Section 3)"], [
  ["Chicken", "Fry the eggs in the pan. Lay the chicken and cabbage on top and cook 1 minute. Flip onto the chapati, spread the sauce, roll."],
  ["Beef", "Fry the eggs. Add the beef, cabbage and green pepper and cook 1 minute. Put on the chapati, spread the sauce, roll."],
  ["Sausage", "Fry the eggs. Add the sausage slices, cabbage, onions and tomatoes and cook 1 minute. Put on the chapati, spread the sauce, roll."],
  ["Spicy Vegetable", "Fry the vegetables 2 minutes with salt, garlic and pilipili. Fry the eggs separately and put the vegetables on top. Put on the chapati, spread the sauce with extra chilli, roll."],
]));
add(note("Keep the sauce separate and spread it only when serving, so the chapati does not go soggy. Wrap in foil or paper to keep it tight."));
add(H2("Other sauces for specials (only after the house sauce works)"));
add(table([2300, 7338], ["Sauce", "What goes in"], [
  ["Garlic yogurt, for beef", "4 spoons plain yogurt or mala, 1 small garlic crushed, a squeeze of lemon, a pinch of salt."],
  ["Honey-mustard yogurt, for chicken", "4 spoons yogurt, 1 spoon honey, 1 spoon mustard (½ if strong), a pinch of black pepper."],
  ["Spicy ketchup yogurt, for sausage", "3 spoons yogurt, 2 spoons tomato ketchup, chilli to taste, a tiny pinch of sugar."],
  ["Avocado, or peanut", "Avocado: ripe avocado, lemon juice, garlic, salt, a little water, blended smooth. Peanut: peanut butter, warm water, lemon, garlic, a little sugar, chilli if you like, stirred smooth."],
]));

// Appendix B
add(H1("Appendix B. Shopping list for 100 Rolexes", true));
add(P("Scaled from the recipes: 25 of each of the four Rolexes. Fill in the unit prices after visiting the market. The total divided by 100 is our **real cost per Rolex**, to compare with the UGX 5,000 to 6,000 the research assumed.", { keepNext: true }));
add(table([2700, 2200, 2538, 1100, 1100], ["Item", "Per Rolex or batch", "For 100 Rolexes", "Unit price", "Cost"], [
  { phase: "Every Rolex" },
  ["Chapati", "1", "100", "[[ ]]", "[[ ]]"],
  ["Eggs", "2", "200 (about 7 trays of 30)", "[[ ]]", "[[ ]]"],
  ["Cabbage, shredded", "1 handful", "100 handfuls", "[[ ]]", "[[ ]]"],
  ["Foil or paper wrap", "1", "100", "[[ ]]", "[[ ]]"],
  { phase: "Fillings (25 of each)" },
  ["Cooked chicken strips", "½ cup", "12½ cups", "[[ ]]", "[[ ]]"],
  ["Cooked beef strips", "½ cup", "12½ cups", "[[ ]]", "[[ ]]"],
  ["Sausages", "1 to 2", "25 to 50", "[[ ]]", "[[ ]]"],
  ["Onions, tomatoes, green pepper, garlic, carrots", "Some in each Rolex", "[[quantity from test run]]", "[[ ]]", "[[ ]]"],
  ["Pilipili (for the vegetable Rolex)", "2 to 3", "50 to 75", "[[ ]]", "[[ ]]"],
  ["Salt, black pepper, Royco", "To taste", "[[quantity from test run]]", "[[ ]]", "[[ ]]"],
  { phase: "House sauce (about 10 batches)" },
  ["Plain yogurt or mala", "1 cup per batch", "10 cups (about 2.4 litres)", "[[ ]]", "[[ ]]"],
  ["Tomato ketchup", "2 spoons per batch", "20 spoons", "[[ ]]", "[[ ]]"],
  ["Cooking oil, for the sauce", "1 spoon per batch", "10 spoons", "[[ ]]", "[[ ]]"],
  ["Garlic", "1 small per batch", "10 small", "[[ ]]", "[[ ]]"],
  ["Lemons", "½ per batch", "5", "[[ ]]", "[[ ]]"],
  ["Sugar", "½ spoon per batch", "5 spoons", "[[ ]]", "[[ ]]"],
  { phase: "Cooking" },
  ["Cooking oil for frying, and gas or charcoal", "", "[[estimate from test run]]", "[[ ]]", "[[ ]]"],
  { cells: ["Total for 100 Rolexes", "", "", "", "[[total]]"], bold: true, fill: PHASE },
  { cells: ["Cost of one Rolex (total ÷ 100)", "", "", "", "[[ ]]"], bold: true, fill: PHASE },
]));
add(note("Chips and soda for the Premium Combo are not costed in the research. Add them once Premium is confirmed."));

// Appendix C
add(H1("Appendix C. Where the numbers come from, and what is not checked"));
add(table([2800, 3300, 3538], ["What", "Where it came from", "Status"], [
  ["Recipes, sauces and method", "A friend's chat with Meta AI, 20 November 2026.", "Not tested. The test run will confirm."],
  ["Rolex prices in Kampala (10,000 to 16,000 at a parlour, 11,500 on Glovo, 20,000 in a restaurant)", "The same chat. One source reference in it is garbled.", "Not verified. 2023 reporting put a street Rolex under one US dollar, so these may be premium prices. Visit sellers."],
  ["\"About UGX 48,000 to 51,000 if sold separately\"", "The same chat.", "Does not add up. The four prices the chat lists total 55,000, and it gives no price for sausage. Recheck after our own price visits."],
  ["Cost of UGX 5,000 to 6,000 per Rolex", "The same chat, as an \"if your cost is\" example.", "An assumption. Replace with the test-run result."],
  ["Combo prices and profit", "The same chat.", "Arithmetic checked: 35,000 ÷ 4 = 8,750 per Rolex, and the profit figures follow from the cost assumption. The Mini is dearer per Rolex than the Full Combo."],
  ["KCCA events checklist", "kcca.go.ug/uploads/KCCA_Events_checklist.pdf, read 20 November 2026.", "Checked against KCCA's own page."],
  ["Public Order Management Act 2013", "Act text on bills.parliament.ug, read 20 November 2026.", "Wording checked. Whether it covers a food festival is not settled. Ask the police."],
  ["Ingredient price rises", "Africanews, 9 July 2023.", "2023 figures. Check current prices."],
  ["A Rolex costs under one US dollar", "Christian Science Monitor, 27 April 2023.", "A 2023 figure. Context only."],
  ["Date, venue, crowd, total budget", "Not in the research.", "These are the yellow items. We need them from the team."],
]));

// ---------- document ----------
const doc = new Document({
  creator: "Festival team",
  title: "Monthly Rolex Festival: Proposal and plan",
  description: "Proposal and plan for a monthly Rolex food festival",
  styles: {
    default: { document: { run: { font: FONT, size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { font: FONT, size: 32, bold: true, color: BRAND },
        paragraph: { spacing: { before: 360, after: 140 }, keepNext: true, keepLines: true, outlineLevel: 0,
          border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "E7C9A9", space: 3 } } } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { font: FONT, size: 25, bold: true, color: "292524" },
        paragraph: { spacing: { before: 240, after: 100 }, keepNext: true, keepLines: true, outlineLevel: 1 } },
    ],
  },
  numbering: {
    config: [{ reference: "bullets", levels: [{ level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
      style: { paragraph: { indent: { left: 540, hanging: 270 } } } }] }],
  },
  sections: [{
    properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1134, bottom: 1134, left: 1134, right: 1134, footer: 560 } } },
    footers: {
      default: new Footer({ children: [new Paragraph({
        tabStops: [{ type: TabStopType.RIGHT, position: W }],
        border: { top: { style: BorderStyle.SINGLE, size: 4, color: "D6D3D1", space: 4 } },
        children: [
          new TextRun({ text: "Monthly Rolex Festival. Proposal and plan. Draft, 20 November 2026.", size: 17, color: GREY, font: FONT }),
          new TextRun({ children: ["\tPage ", PageNumber.CURRENT, " of ", PageNumber.TOTAL_PAGES], size: 17, color: GREY, font: FONT }),
        ],
      })] }),
    },
    children: kids,
  }],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync(OUT, buf);
  console.log("Wrote", OUT, buf.length, "bytes");
});
