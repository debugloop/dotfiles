---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

Load the `codebase-design` skill before you start. Use its architecture vocabulary and principles throughout the review. Read its `DEEPENING.md` file before you assess dependencies.

The domain language in `CONTEXT.md` gives names to good seams. ADRs in `docs/adr/` record decisions that this command must not re-open without evidence.

## Process

### 1. Set the scope

Favor areas that change often. Deepening a stable module has little value.

- If the user names a module, subsystem, or pain point, use that scope.
- Otherwise, inspect a useful part of `git log --oneline` and identify repeated hot spots.
- If history has no clear hot spot, widen the scan.

Read the project's domain glossary and relevant ADRs before you inspect the code.

### 2. Explore

Explore the selected area directly. Do not require an `Agent` or sub-agent tool. Note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the deletion test to each shallow module. A useful module causes complexity to spread when you remove it.

Classify each candidate's dependencies with [`DEEPENING.md`](../codebase-design/DEEPENING.md). Do not add a seam only for testing.

### 3. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

The report uses **Tailwind via CDN** for layout and styling, and **Mermaid via CDN** for diagrams where a graph/flow/sequence reliably communicates the structure. Mix Mermaid with hand-crafted CSS/SVG visuals — use Mermaid when relationships are graph-shaped (call graphs, dependencies, sequences), and hand-built divs/SVG when you want something more editorial (mass diagrams, cross-sections, collapse animations). Each candidate gets a **before/after visualisation**. Be visual.

For each candidate, render a card with:

- **Files** — which files/modules are involved
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage, and how tests would improve
- **Before / After diagram** — side-by-side, custom-drawn, illustrating the shallowness and the deepening
- **Recommendation strength** — one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

**Use `CONTEXT.md` vocabulary for the domain and `codebase-design` vocabulary for the architecture.** If `CONTEXT.md` defines "Order," use "the Order intake module," not "the FooBarHandler" or "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly in the card (e.g. a warning callout: _"contradicts ADR-0007 — but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?"

### 4. Decision interview

Once the user picks a candidate, interview them about constraints, dependencies, the deepened module, its seam, and the tests that survive.

Ask one question at a time. Give your recommended answer with each question, then wait for the user's answer.

Load the `domain-modeling` skill when the discussion changes domain terms or decisions:

- **Naming a deepened module after a concept not in `CONTEXT.md`?** Add the term to `CONTEXT.md`. Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `CONTEXT.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones.
- **Want to explore alternative interfaces for the deepened module?** Read [`DESIGN-IT-TWICE.md`](../codebase-design/DESIGN-IT-TWICE.md). Produce at least three designs before you compare them.
