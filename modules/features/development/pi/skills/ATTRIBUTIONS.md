# Skill attributions

Several skills in this directory are adapted from Matt Pocock's public skills repository:

- Repository: <https://github.com/mattpocock/skills/tree/main>
- License: MIT License, Copyright (c) 2026 Matt Pocock
- Upstream `main` checked while writing this attribution: `66898f60e8c744e269f8ce06c2b2b99ce7660d5f`

These copies have been modified for my personal Pi/Nix agent setup, including changes to workflow assumptions, tool usage, repo conventions, and local agent guidance.

The `ste-writing` skill is copied from Ege Çelebi's blog repository:

- Source: <https://github.com/woosal1337/blog/tree/main/videos/ep01-the-cure-for-ai-slop>
- License: MIT License, Copyright (c) 2026 Ege Çelebi
- Upstream commit: `51100c98f20022746d340db657a34bf71bfe77b9`

### MIT license notice for `ste-writing`

Copyright (c) 2026 Ege Çelebi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Upstream note: this license covers the source code only. Blog post text and images under `app/(website)/blog` and `public/` are © Ege Çelebi, all rights reserved.

## Per-skill sources

| Local skill | Attribution / source | Notes |
| --- | --- | --- |
| `code-review` | Adapted from `skills/engineering/code-review` in Matt Pocock's skills repo. | Modified for the local two-axis review workflow and repo standards/spec conventions. |
| `diagnose` | Adapted from `skills/engineering/diagnosing-bugs` in Matt Pocock's skills repo. | Renamed locally; includes the adapted `scripts/hitl-loop.template.sh`. |
| `domain-modeling` | Adapted from `skills/engineering/domain-modeling` in Matt Pocock's skills repo. | Includes the adapted `ADR-FORMAT.md` and `CONTEXT-FORMAT.md` support files. |
| `explain-html` | Local skill. The skill metadata separately notes it is based on Geoffrey Litt's gist: <https://gist.github.com/geoffreylitt/a29df1b5f9865506e8952488eac3d524>. | Not identified as adapted from Matt Pocock's skills repo. |
| `explain-nvim` | Local skill. | Built as a Neovim/live-editor counterpart to `explain-html`; not identified as adapted from Matt Pocock's skills repo. |
| `grill-with-docs` | Adapted from `skills/engineering/grill-with-docs` in Matt Pocock's skills repo. | Local wrapper around grilling plus domain-modeling. |
| `grilling` | Adapted from `skills/productivity/grilling` in Matt Pocock's skills repo. | Modified for local clarification/question flow. |
| `implement` | Adapted from `skills/engineering/implement` in Matt Pocock's skills repo. | Heavily modified to avoid issue-tracker workflow and commits by default. |
| `improve-codebase-architecture` | Adapted from `skills/engineering/improve-codebase-architecture` in Matt Pocock's skills repo. | Includes the adapted `HTML-REPORT.md` support file. |
| `prototype` | Adapted from `skills/engineering/prototype` in Matt Pocock's skills repo. | Includes the adapted `LOGIC.md` and `UI.md` support files. |
| `resolving-merge-conflicts` | Adapted from `skills/engineering/resolving-merge-conflicts` in Matt Pocock's skills repo. | Modified for local merge/rebase expectations. |
| `review` | Local alias skill. | Points to the local `code-review` skill, which is adapted from Matt Pocock's `skills/engineering/code-review`. |
| `ste-writing` | Copied from `videos/ep01-the-cure-for-ai-slop` in Ege Çelebi's blog repo. | Includes the linter and recurring-errors reference; the MIT notice appears above. Markdown is normalized by the repo formatter. |
| `tdd` | Adapted from `skills/engineering/tdd` in Matt Pocock's skills repo. | Includes the adapted `mocking.md` and `tests.md` support files. |
| `to-spec` | Adapted from `skills/engineering/to-spec` in Matt Pocock's skills repo. | Modified for local spec-writing and non-issue-tracker workflow. |
| `to-tasks` | Adapted from `skills/engineering/to-tickets` in Matt Pocock's skills repo. | Renamed and reworked from ticket publication into a human-owned task checklist workflow. |
