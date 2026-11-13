---
description: "Encoding the global constraints of a domain in Lean lets you derive a runtime specialized to it. That took my submission to #1 on the $12 server challenge, ahead of C and Rust."
author: Harsh Gupta
author_url: https://x.com/hargup13
date: October 30, 2026
subtitle: false
---

# Deriving the runtime to get to #1 on $12 challenge

<i>The post was published on 13th November, but I'm predating it to the date of the tweet to maintain the chronological record and proof of work</i>

<!-- Human written start, do not edit -->
In the [previous post](/blog/domain_driven_development/), I described how Lean can be used for precisely and abstractly describing the domain you're working with, which I called domain driven development. This obviously reduces bugs. The less understood fact is that domain driven development can also make your code fast, like really fast.

Your hardware does not understand HTTP requests, or databases, or UI or any of these high-level concepts. The hardware understands very low level concepts like move this data from this pointer to this pointer, and do this computation on the data written at this pointer. So your high-level concepts need to be translated to the low-level. And this translation is done layer by layer. Each layer carries its own assumptions, and introduces its own inefficiencies. 

Usually, your language will have something called a "runtime" which dynamically does this high-level to low-level translation. This runtime isn't always the fastest for your application because the runtime is written to support a lot of different kinds of applications. Languages like Rust and C have a very thin and low-level runtime, so you get to control lots of low-level details making your code fast, but obviously it becomes hard to write low-level code directly. Languages like Python and JavaScript have thick runtimes and they handle a lot of stuff for you, but ofc making things slow.

In Lean, you can "derive the runtime", meaning, you can describe the high level behavior of your software, and generate the low-level code to implement that behavior, skipping the buggy and inefficient middle layers. Because Lean makes it easy to describe the global constraints and invariants of your software, you can have the low-level code carry over the high level invariants and only do what you really need to do.


I used this technique on the [$12 server challenge](https://github.com/arjaythedev/twelve-dollar-server-challenge) and got to number one on the leaderboard, ahead of the C and Rust submissions. You can find the submission below. The creator of the challenge also made a good video about it, which you can watch in the tweet below. I was pretty happy to see the tweet go kind of viral on Twitter.

<!-- Human written start, do not edit -->




Submission: [lean-derive-hargup](https://github.com/arjaythedev/twelve-dollar-server-challenge/tree/main/submissions/lean-derive-hargup)

<blockquote class="twitter-tweet" data-dnt="true" data-align="center"><p lang="en" dir="ltr">It&#39;s official now, my Lean 4 submission is #1 on &quot;$12 server challenge&quot;, serving more users than Rust, C or even hand written assembly.<br><br>The creator of a the challenge did a pretty good job explaining how Lean 4 allows you to create software even more optimized than handwritten C. <a href="https://t.co/cnQ10nhkJZ">pic.twitter.com/cnQ10nhkJZ</a></p>&mdash; Harsh Gupta (@hargup13) <a href="https://twitter.com/hargup13/status/2116422880221409621">October 30, 2026</a></blockquote>

Thanks!
