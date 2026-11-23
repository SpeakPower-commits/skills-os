'use strict';
// Builds ..\everyone-says-lead-with-one-story.docx from ..\article.md and the images folder.
// One-time setup: in an empty folder run `npm install docx --ignore-scripts`, then
//   $env:NODE_PATH = '<that folder>\node_modules'
//   node build-docx.js
const fs = require('fs');
const path = require('path');
const {
  Document, Packer, Paragraph, TextRun, ImageRun, AlignmentType, BorderStyle,
  Table, TableRow, TableCell, WidthType, Footer, PageNumber, TabStopType,
  HeadingLevel, VerticalAlign,
} = require('docx');

const ROOT = path.resolve(__dirname, '..');
const OUT = path.join(ROOT, 'everyone-says-lead-with-one-story.docx');
const NAVY = '0D172A', GOLD = 'F2B720', INK = '1E2433', SLATE = '5A6378';
const BODY = { font: 'Georgia', size: 22, color: INK };
const NONE = { style: BorderStyle.NONE, size: 0, color: 'FFFFFF' };

const smart = (s) => s
  .replace(/(^|[\s(\[])"/g, '$1“').replace(/"/g, '”')
  .replace(/(^|[\s(\[])'/g, '$1‘').replace(/'/g, '’');

function runs(text, base = BODY) {
  return text.split(/(\*\*[^*]+\*\*|\*[^*]+\*)/g).filter(Boolean).map((p) => {
    if (p.startsWith('**')) return new TextRun({ ...base, text: p.slice(2, -2), bold: true, color: NAVY });
    if (p.startsWith('*')) return new TextRun({ ...base, text: p.slice(1, -1), italics: true });
    return new TextRun({ ...base, text: p });
  });
}

const read = (f) => fs.readFileSync(path.join(ROOT, 'images', f));

// Sizes in pixels at 96 dpi. A4 with 2 cm margins leaves 17 cm = 642 px.
const SIZES = {
  '02-two-studies.png':         { w: 600, h: 338, type: 'png' },
  '03-five-parts.png':           { w: 400, h: 400, type: 'png' },
  '04-before-after.png':         { w: 400, h: 500, type: 'png' },
};

function picture(file, alt, title) {
  const s = SIZES[file];
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 240, after: 240 },
    children: [new ImageRun({
      type: s.type, data: read(file),
      transformation: { width: s.w, height: s.h },
      altText: { title, description: alt, name: file },
    })],
  });
}

function authorCard() {
  const label = { font: 'Arial', color: NAVY };
  return new Table({
    width: { size: 9638, type: WidthType.DXA },
    columnWidths: [1700, 7938],
    borders: { top: { style: BorderStyle.SINGLE, size: 18, color: GOLD }, bottom: NONE, left: NONE, right: NONE, insideHorizontal: NONE, insideVertical: NONE },
    rows: [new TableRow({
      children: [
        new TableCell({
          width: { size: 1700, type: WidthType.DXA }, verticalAlign: VerticalAlign.CENTER,
          borders: { top: NONE, bottom: NONE, left: NONE, right: NONE },
          margins: { top: 200, bottom: 120, left: 0, right: 120 },
          children: [new Paragraph({ children: [new ImageRun({
            type: 'png', data: read('06-author-tom.png'), transformation: { width: 96, height: 96 },
            altText: { title: 'Thomas Otieno', description: 'Portrait of Thomas Otieno, smiling, in glasses and a blue checked shirt.', name: '06-author-tom.png' },
          })] })],
        }),
        new TableCell({
          width: { size: 7938, type: WidthType.DXA }, verticalAlign: VerticalAlign.CENTER,
          borders: { top: NONE, bottom: NONE, left: NONE, right: NONE },
          margins: { top: 200, bottom: 120, left: 120, right: 0 },
          children: [
            new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ ...label, text: 'Thomas Otieno', bold: true, size: 26 })] }),
            new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ font: 'Georgia', size: 19, italics: true, color: SLATE, text: 'Strategy & Market Development Expert | Data-Driven Communications Architecture | Brand Storytelling' })] }),
            new Paragraph({ children: [new TextRun({ font: 'Arial', size: 18, color: SLATE, text: 'SpeakPower, Kampala' })] }),
          ],
        }),
      ],
    })],
  });
}

const md = fs.readFileSync(path.join(ROOT, 'article.md'), 'utf8').replace(/<!--[\s\S]*?-->/g, '');
const lines = md.split(/\r?\n/);
const kids = [];

// Cover photo
kids.push(new Paragraph({
  spacing: { after: 200 },
  children: [new ImageRun({
    type: 'png', data: read('01-hero.png'), transformation: { width: 642, height: 335 },
    altText: { title: 'Cover', description: 'A gold and navy cover with a ruled funding proposal page. The words lead with one story are circled in red pen with a note asking who says so, and a sticky note asks what they tested.', name: '01-hero.png' },
  })],
}));

let sixChecksIdx = -1, firstCheckIdx = -1;
let lastTextIdx = -1;
lines.forEach((l, i) => { if (l.trim()) lastTextIdx = i; });

for (let i = 0; i < lines.length; i++) {
  const raw = lines[i].trim();
  if (!raw) continue;
  let m;
  if ((m = raw.match(/^# (.+)$/))) {
    kids.push(new Paragraph({ spacing: { before: 120, after: 60 }, keepNext: true,
      children: [new TextRun({ font: 'Arial', size: 18, bold: true, color: 'B88400', characterSpacing: 40, text: 'NGO STORYTELLING' })] }));
    kids.push(new Paragraph({ heading: HeadingLevel.TITLE, children: [new TextRun({ text: smart(m[1]) })] }));
    kids.push(new Paragraph({ spacing: { after: 280 },
      children: [new TextRun({ font: 'Arial', size: 20, color: SLATE, text: 'By Thomas Otieno, SpeakPower, Kampala' })] }));
    continue;
  }
  if ((m = raw.match(/^## (.+)$/))) {
    kids.push(new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun({ text: smart(m[1]) })] }));
    continue;
  }
  if ((m = raw.match(/^!\[(.*?)\]\((.*?)\)$/))) {
    const file = path.basename(m[2]);
    let alt = m[1];
    let j = i + 1;
    while (j < lines.length && !lines[j].trim()) j++;
    const am = j < lines.length && lines[j].trim().match(/^\*Alt text: (.+)\*$/);
    if (am) { alt = am[1]; i = j; }
    if (SIZES[file]) {                                       // the vector hero is skipped; the photo is the cover
      if (file === '03-five-parts.png') sixChecksIdx = kids.length;
      kids.push(picture(file, alt, m[1]));
    }
    continue;
  }
  if (i === lastTextIdx && raw.startsWith('*Thomas Otieno')) {
    kids.push(new Paragraph({ spacing: { before: 360 }, children: [] }));
    kids.push(authorCard());
    continue;
  }
  if (raw.startsWith('**1. Who.')) firstCheckIdx = kids.length;
  kids.push(new Paragraph({ spacing: { after: 170, line: 340 }, keepLines: true, children: runs(smart(raw)) }));
}

// In the Word edition the six-checks graphic leads into the list instead of following it,
// so it fits under the intro on the same page rather than leaving a gap.
if (sixChecksIdx > firstCheckIdx && firstCheckIdx >= 0) {
  const [pic] = kids.splice(sixChecksIdx, 1);
  kids.splice(firstCheckIdx, 0, pic);
}

const doc = new Document({
  creator: 'Thomas Otieno',
  title: 'Everyone Says Lead With One Story. The Evidence Is Shakier Than That.',
  description: 'SpeakPower article on storytelling for NGO funders.',
  styles: {
    default: { document: { run: BODY } },
    paragraphStyles: [
      { id: 'Title', name: 'Title', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: 'Arial', size: 52, bold: true, color: NAVY },
        paragraph: { spacing: { before: 60, after: 120, line: 250 }, keepNext: true } },
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: 'Arial', size: 40, bold: true, color: NAVY },
        paragraph: { spacing: { before: 360, after: 160 }, keepNext: true, outlineLevel: 0 } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: 'Arial', size: 30, bold: true, color: NAVY },
        paragraph: { spacing: { before: 480, after: 150 }, keepNext: true, outlineLevel: 1,
          border: { top: { style: BorderStyle.SINGLE, size: 18, color: GOLD, space: 8 } } } },
    ],
  },
  sections: [{
    properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1134, right: 1134, bottom: 1134, left: 1134 } } },
    footers: { default: new Footer({ children: [new Paragraph({
      tabStops: [{ type: TabStopType.RIGHT, position: 9638 }],
      children: [
        new TextRun({ font: 'Arial', size: 16, color: SLATE, text: 'SpeakPower | NGO storytelling' }),
        new TextRun({ font: 'Arial', size: 16, color: SLATE, children: ['\tPage ', PageNumber.CURRENT] }),
      ],
    })] }) },
    children: kids,
  }],
});

Packer.toBuffer(doc).then((buf) => { fs.writeFileSync(OUT, buf); console.log('Wrote ' + OUT + ' (' + buf.length + ' bytes)'); });
