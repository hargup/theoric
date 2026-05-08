# theoric.com

Static site for Theoric — applied AI lab. Hand-written HTML, no build step, hosted on GitHub Pages via the `CNAME` file.

This README is the design brief for the site. Anything you add (new page, social asset, slide, doc) should pass these rules so we stay consistent.

The master brand brief (logo construction, avatar generation, full token list) lives at `../theoric-design-brief.md`. This README is the working subset for site work.

## Brand snapshot

- **Theoric** — the lab/company. Parent brand.
- **Clockworks** — the GPU verification product. Surfaced in the manifesto and product copy; everything else stays under Theoric.
- Positioning: *Applied AI lab. Provably correct, provably optimal GPU software.*
- North-star feel: a Bell Labs technical memorandum, c. 1968. Prose-first. No ornament that isn't load-bearing.

## Color

| Token | Hex | Use |
|---|---|---|
| Theoric Black | `#101010` | Body text, logo, links, all primary ink |
| Precision White | `#FAFAF8` | Page background, avatar field |
| Graphite | `#4F5357` | Captions, secondary type (reserved; not in heavy use yet) |
| Date Gray | `#555` | Post dates and muted inline text |
| Signature Gray | `#444` | Author signature blocks |
| Steel Gray | `#D8DDE1` | Hairlines, borders, favicon stroke |
| Signal Blue | `#2D6BFF` | Reserved digital accent — UI states only, never on the logo |

Forbidden: pure black `#000`, pure white `#fff`, gradients, glow, drop shadows, 3D renders.

## Typography

**The wordmark is a custom vector — not a font. Do not recreate it as live text.** Use the SVG.

For live text that wants to *feel* like the wordmark (display headers in a social asset, slide title): design ref is **Eurostile Next Extended Black**; open-web fallback is **Orbitron Bold** with uppercase tracking 0.12–0.18em.

For site body, headings, links — the system stack:

```
-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif
```

Weights: 400 body, 600 max for headings. **Do not introduce another typeface in site copy.**

## Logo & wordmark assets

In `assets/`:

| File | What it is | When to use |
|---|---|---|
| `theoric-stylized-wordmark.svg` | Wordmark with the structural T-mark serving as the first letter | **Default** — every page on the site uses this |
| `theoric-wordmark.svg` | Wordmark only, no T prefix | Tight horizontal space, or when the T-mark already appears nearby |
| `theoric-logo.svg` | Standalone T-mark + wordmark, side by side | Wide formats — cover slides, signage, social headers |
| `favicon.svg` | T-mark inside rounded-square tile | Browser favicon, profile picture, app icon |

In the parent `theoric_design_assets/` directory: stacked lockup, mark-only SVG, and PNG masters at avatar sizes for X/LinkedIn upload. Refer to `../theoric-design-brief.md` for the full inventory.

**Logo rules**:
- Clear space ≥ 25% of the mark height on every side.
- Min primary lockup width: 160px digital, 38mm print.
- Min standalone T-mark width: 24px digital, 7mm print.
- Use Theoric Black on light fields. Use Precision White on dark fields.
- Never stretch, skew, outline, drop-shadow, gradient-fill, or recolor the mark.

## Layout (site)

- Body: `max-width: 680px`, centered.
- Padding: `4rem 2rem`.
- Line-height: `1.7`.
- Font-size: `16px`.
- Logo block: `width: 220px`, `margin-bottom: 3rem`.
- H1 inside an article (blog post, manifesto): `1.8rem`, `600`, `line-height: 1.25`.
- H1 on index pages (Blog): `1.6rem`, `600`.
- Date row: `color: #555`, `display: block`.
- Links: ink color, underlined, `text-decoration-thickness: 1px`, `text-underline-offset: 0.18em`.
- Footer: `display: flex`, `gap: 1rem`, `font-size: 0.95rem`. Standard slots: `Home`, `Blog`, `Contact`.

## Page-head requirements

Every page must include in `<head>`:

- `<meta charset="UTF-8">`
- `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
- `<title>` — sentence-case page title, ending in ` | Theoric` (homepage is just `Theoric`)
- `<meta name="description">` — one sentence, ≤160 chars
- `<link rel="canonical">` — absolute URL on https://theoric.com
- `<link rel="icon" href="…/favicon.svg" type="image/svg+xml">`
- Open Graph: `og:title`, `og:description`, `og:type` (`website` or `article`), `og:url`
- Twitter: `twitter:card="summary"`, `twitter:title`, `twitter:description`

`og:image` is intentionally absent until we have a proper social card asset.

## Voice & tone

- Prose-first. Plain English. No filler.
- The **manifesto** register is informal and punchy (*"sucks!"*, *"boom"*). The **blog** is institutional and measured. The **homepage** is the most restrained — three short paragraphs.
- Personal essays carry the author's signature (`Harsh Gupta` + `hargup.in`). Institutional pieces (homepage, blog index, product copy) do not.
- Don't write headers or sections that aren't necessary. If a paragraph carries the load, let it.

## Adding a new blog post

1. Make a directory: `blog/<slug>/index.html`. Slugs are lowercase, hyphenated, ASCII.
2. Copy an existing post (`every-problem-is-a-software-problem` is a good baseline) as the template.
3. Update: `<title>`, meta description, canonical URL, OG tags, Twitter tags, h1, date, body.
4. **Date format**: `Month D, YYYY` (e.g. *February 7, 2026*). No ordinals, no abbreviations.
5. **Title casing**: sentence case, except proper nouns and product names (*Lean 4*, *Clockworks*, *Theoric*).
6. Add an entry to `blog/index.html` in reverse-chronological position.

## Don'ts

- No gradients, glow, drop shadows, 3D renders.
- No AI-cliché imagery: brains, neural-network nodes, glowing chips, blue-purple haze.
- No emoji in copy, in commits, or in file names.
- No analytics, ads, third-party trackers, or JS frameworks. The site is hand-written static HTML by design.
- No new typefaces in site CSS.
- No comments inside HTML/CSS unless the *why* would surprise a reader.

## File / directory conventions

- HTML: one `index.html` per directory. URLs are clean (`/blog/<slug>/`, no `.html` extension exposed).
- Assets: SVG-first. Raster PNGs only for social uploads (X/LinkedIn avatars), and they live in the parent design-assets folder, not in this repo.
- New SVG icons: 24×24 viewBox, `currentColor` fills, no fixed colors baked in.

## Domain & contact

- Live: https://theoric.com (CNAME → GitHub Pages)
- Contact: team@theoric.com
