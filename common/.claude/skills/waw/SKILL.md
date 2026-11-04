---
name: waw
description: Where are we — recap this session (initial request, what's done, what's left, blockers, open decisions) so I can get back into it fast.
disable-model-invocation: true
---

Pause the task. Don't resume it and don't run tools to make progress. I've lost track of this session and need to get back into it in 30 seconds.

Build the recap from the conversation itself. If the conversation was compacted, say so first: the early part comes from a summary and may be incomplete. You may run read-only commands (git status, git diff --stat, git log) to check that what you call done actually exists. Never use them to continue the work.

Sections, in this order. Bullets only, one line per bullet:

**Demande initiale**: my first request, quoted or close to word for word. Then, if the goal shifted along the way, one bullet per shift: what changed and why.

**Fait**: what's done. Mark "(non vérifié)" on anything you did but never checked (tests not run, page not rendered, command not executed).

**En cours**: what was in progress when we stopped, and exactly where it stopped.

**Reste à faire**: the remaining work, in the order you would do it, each item marked as yours or mine. The first item is the next action.

**Blockers**: what's stopping progress, and who can unblock it (me, you, someone else). Leave the section out if there are none.

**Décisions à prendre**: each open decision as a question I can answer, with the options and your recommendation. Include decisions you made on your own that I never approved. Leave it out if there are none.
Rules:
- Only facts from this session. If something is unclear, say so instead of filling the gap.
- Name files, PRs, branches and commands exactly as they are, so I can find them.
- No intro, no conclusion.
- The whole recap must fit on one screen.
