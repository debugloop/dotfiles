---
name: explain-nvim
description: Walk the user through the changes since a fixed point (commit, branch, tag, or merge-base) as a guided, interactive code tour — the live Neovim counterpart to the `explain-html` skill. Drives the user's Neovim (scroll, highlight, virtual-text annotations) when connected, and degrades to prose with file:line references otherwise. Advances one stop at a time and waits for the user to say "next". Use when the user wants to be walked through a diff/branch/PR, asks for a guided tour or walkthrough of changes, or says "tour since X" / "lead me through the changes".
disable-model-invocation: true
---

# Explain (Neovim)

A guided walkthrough of the diff between `HEAD` and a fixed point the user
supplies. This is the **live Neovim counterpart to `explain-html`**: same story,
same section order, same voice — but delivered *in the editor* as an annotated
walk through the real code, rather than as a standalone HTML file.

Where `explain-html` writes a document, this walks the user through the change
on the actual buffers: highlighting the diff, annotating each stop with inline
virtual text, and moving the cursor one stop at a time while you narrate. When
Neovim is not reachable, degrade to prose + `file:line` (see end).

## The story (mirror `explain-html`)

Structure the whole walkthrough as the same movements the `explain-html` skill
uses, and write with the same clarity and flow — engaging, classic style, smooth
transitions, the essence before the detail:

1. **Background** — the existing system this change touches. Explore the
   surrounding code, not just the diff. Give the beginner enough to follow, then
   narrow to what's directly relevant. This is spoken up front, before the first
   stop.
2. **Intuition** — the core idea of the change in one or two sentences, with a
   concrete toy example. Essence, not detail. Deliver this as you land on the
   first substantive stop.
3. **Code** — the high-level walkthrough of the actual changes, grouped in an
   understandable order (this *is* the itinerary — see below).

(The `explain-html` skill closes with a Quiz; the live walk does not — it ends
when the last stop is done.)

## Neovim conventions (pi)

Pi reaches Neovim through the generic `msgpack_rpc_call` tool (raw `nvim_*` RPC)
plus `discover_neovim`. There is no MCP annotation helper and no keypress→agent
callback, so the walk keeps the agent **in the loop**: annotate up front, land
on a stop, narrate, then wait for the user to say "next" and advance the cursor
yourself. Follow these conventions throughout:

- **State before acting.** Before each turn's Neovim work, re-check the live
  state (`nvim_get_current_buf`, `nvim_win_get_cursor`, buffer list). Never carry
  cursor position or file identity across turns.
- **Buffer over disk.** If a file is already loaded as a buffer, read/inspect it
  via buffer RPC (`nvim_buf_get_lines`), not disk — what the user sees is the
  buffer.
- **Annotations are extmark virtual text**, all `※ `-prefixed. Use
  `nvim_buf_set_extmark` with `virt_lines` (for `above`-style notes) or
  `virt_text` (for end-of-line notes) on a dedicated namespace
  (`nvim_create_namespace("explain-nvim")`) so you can clear them cleanly at wrap-up.
- **Palette** (colorscheme-adaptive highlight groups): `DiagnosticWarn` by
  default (reads well, adapts) — reach for another `Diagnostic*` group only when
  semantics demand it (`DiagnosticError`, `DiagnosticInfo`, `DiagnosticHint`,
  `DiagnosticOk`). For full-line backgrounds prefer a group with a real
  background (`Visual`, `DiffAdd`) over foreground-only groups.
- **Indexing.** `nvim_buf_*` and extmark rows are 0-based; `nvim_win_get_cursor`
  row is 1-based, col 0-based. Report positions to the user as 1-based.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch, tag, `main`,
`HEAD~5`, etc. Pass it through; don't be opinionated. If they didn't give one,
ask: "Tour the changes against what — a branch, a commit, or `main`?" Don't
proceed until you have it.

Resolve the merge-base once: `git merge-base HEAD <fixed-point>`. Capture the
diff (`git diff <merge-base>...HEAD`) and commit list
(`git log <merge-base>..HEAD --oneline`).

### 2. Build the itinerary (the "Code" walkthrough)

Read the full diff and group the changes into a **logical narrative order**, not
file-alphabetical order. Good ordering heuristics:

- **Dependency order**: foundational/new types first, then the code that
  consumes them, then the wiring that connects it all.
- **Data-flow order**: follow one representative path through the change from
  entry point to effect (e.g. "follow a request from creation to execution").

A stop is `{file, line, notes}`. Decide the full ordered list before touching
the editor. State the route briefly (and confirm it if the ordering is
non-obvious) before you start.

### 3. Detect the environment

Call `discover_neovim`.

- **One instance** → drive the editor (annotate + walk, below).
- **Multiple instances** → list them and ask which one (don't guess).
- **None** → degrade to prose mode (see end).

### 4. Set up the diff view and annotate up front

Virtual text can only attach to a **loaded** buffer, so provision before you
start moving:

1. **Show the diff against the base.** Point the git index at the base so the
   user's normal in-editor diff rendering (sign column / gitsigns / inline diff)
   shows the change relative to the base across every buffer:
   `git read-tree <merge-base>`. This is repo-global until reset (wrap-up); that
   is the accepted tradeoff, and it mirrors a "set git base" workflow.
2. **Open every itinerary file** (`nvim_cmd`/`nvim_command` with `edit <file>`,
   or `nvim_call_function("bufload", ...)`) so its buffer is loaded.
3. **Annotate every stop** with extmarks on the `explain-nvim` namespace in one pass
   (conventions below).
4. **Land on stop 1**: open its file and center — `nvim_win_set_cursor` to the
   line, then `nvim_command("normal! zz")`.

### 5. Annotation conventions

All annotations are `※ `-prefixed virtual text on the `explain-nvim` namespace, color
`DiagnosticWarn` by default. Density:

- **Each method/function** in scope gets a note above it (`virt_lines`,
  positioned above) naming it and its role.
- **Each block** you would otherwise call out in prose gets its own note above
  it.
- **Each non-trivial / important line** gets a short end-of-line note
  (`virt_text`).
- Trivial methods stay light (one line).

Style:

- No uppercase prefixes like `METHOD`/`BLOCK` — just the note text.
- **Indent** `above` annotations (after `※ `) to match the indentation of the
  code they sit over.
- When touring related sites **out of source order**, number the labels by
  **tour order**, not source position (the first stop is "1/3" even if it is
  last in the file).
- Prefer inline virtual text over full-line background highlights; line
  backgrounds are visually heavy.

### 6. Walk the tour, one stop at a time

Because pi has no keypress→agent callback, you drive the pacing conversationally:

- On landing at each stop, deliver its narration in the tour voice — Intuition
  at the first substantive stop, then the per-stop "Code" walkthrough. Keep it
  tight; the extmarks carry the detail.
- Then **stop and wait** for the user to say "next" (or ask a question). On
  "next", re-check state, open the next stop's file, move the cursor, center
  (`zz`), and narrate.
- On a question, answer against the real buffer/diff, then offer to continue.

### 7. Wrap up

After the last stop, wrap up: restore the git index (`git reset` — ends the
diff-vs-base view), and offer to clear annotations (`nvim_buf_clear_namespace`
on each touched buffer for the `explain-nvim` namespace). Don't clear without asking —
the user may want to keep them for their own review pass.

## Degraded mode (no Neovim)

Fall back to interactive prose that still follows the same movements: speak the
**Background** up front, then present the **Code** walkthrough one stop at a time
(each stop: a heading naming the file + change, the **Intuition** where relevant,
a 2–4 sentence what/why, and `file:line` references the user can jump to),
waiting for "next" between stops. Same itinerary, same story, same pacing — just
without the live editor.

> If the user would rather have a durable artifact than a live walk, that's the
> `explain-html` skill — same story, rendered as a standalone HTML file (and it
> closes with an interactive quiz).

## Notes

- The tour is **read-only by intent.** Don't edit code during a tour unless the
  user explicitly asks. Annotations, highlights, the git-index base, and any
  keymaps are visual/session state and are reverted at wrap-up.
- Keep annotations tight. The user is reviewing; favor several short notes over
  one sprawling one.
