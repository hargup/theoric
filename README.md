# theoric.com

Source for [theoric.com](https://theoric.com), the website for Theoric — an applied AI lab at the intersection of formal methods and agentic AI.

Static HTML hosted on GitHub Pages, with a small Markdown converter for Markdown-backed posts.

## Build a Markdown post

Posts with a Markdown source can be converted to the adjacent `index.html` with:

```bash
./scripts/build-post blog/drafts/leandb_a_strongly_typed_sql_frontend/post.md
```

To rebuild automatically while editing:

```bash
./scripts/build-post --watch blog/drafts/leandb_a_strongly_typed_sql_frontend/post.md
```

The converter requires [Pandoc](https://pandoc.org/). Each source file must start with YAML metadata for `description`, `author`, `author_url`, and `date`, followed by an H1 title and an opening paragraph.

Contact: team@theoric.com
