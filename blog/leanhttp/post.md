---
description: "Introducing leanhttp, an HTTP client for Lean 4 and part of a larger toolset for writing software in Lean."
author: Harsh Gupta
author_url: https://x.com/hargup13
date: September 21, 2026
subtitle: false
---

# LeanHTTP: A HTTP Client for Lean 4

Introducing leanhttp, a HTTP client for Lean 4.

GitHub: <https://github.com/theoriclabs/leanhttp>

This is part of a larger toolset I've been building around writing general purpose software in Lean:

- [LeanReact](/blog/leanreact_introduction/) for UIs
- [LeanDB](/blog/leandb_a_strongly_typed_sql_frontend/) for database interactions
- Lean’s existing HTTP server support
- now, [leanhttp](https://github.com/theoriclabs/leanhttp) for outbound HTTP/HTTPS requests

Writing an application in Lean does not automatically make the application correct or formally verified. The hard part is preserving the semantics across boundaries.

In the next few posts, I’ll show how to do that.
