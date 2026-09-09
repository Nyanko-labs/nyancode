---
description: Review uncommitted changes for bugs and over-engineering
agent: plan
---
Review this diff. Report only real problems: bugs, security issues, missing error handling at trust boundaries, and unnecessary complexity. One line per finding as `file:line - problem - fix`. Say "LGTM" if nothing is wrong.

!`git diff HEAD --stat && git diff HEAD`

$ARGUMENTS
