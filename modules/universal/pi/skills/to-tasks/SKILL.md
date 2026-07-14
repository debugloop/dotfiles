---
name: to-tasks
description: Break a plan, spec, or current conversation into a short, human-owned task checklist. No issue tracker, labels, queue, or publishing ceremony.
disable-model-invocation: true
---

# To Tasks

Break a plan, spec, or conversation into a set of **tasks**: small, ordered slices that help the human choose the next tightly scoped agent batch.

This is **not** an issue-tracker workflow. The human is the keeper of long-term context and work selection; the agent produces a clear checklist for the current decision/work session.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, PRD path, note file, PR/URL, or other explicit source), fetch it and read its full body/comments where possible.

### 2. Explore the codebase only as needed

If you have not already explored the codebase, do just enough to understand the current shape. Task titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer-bullet tasks**.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer it needs (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each task its **blocking edges** — the other tasks that must complete before it can start. A task with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own task blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a task blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify task — green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each task, show:

- **Title**: short descriptive name
- **Blocked by**: which other tasks (if any) must complete first
- **What it delivers**: the end-to-end behaviour this task makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each task only depend on tasks that genuinely gate it?
- Should any tasks be merged or split further?

Iterate until the user approves the breakdown.

### 5. Capture the task list

Default to an in-chat checklist. If the user asks for a durable artifact, write a markdown file such as `.scratch/<short-feature-slug>/tasks.md`.

If a session-local Pi task/todo extension is available, prefer it for ephemeral checklists the agent will actively maintain during the current session. The Pi examples include a `todo.ts` extension that is a good starting point: it stores state in the session branch, not in repo files, which fits this repo's "human owns roadmap, agent owns current batch" workflow. Do not assume such a tool exists; use it only when it is actually available.

Do **not** create issues, apply labels, claim work, publish to a tracker, or maintain a queue.

<tasks-file-template>

# Tasks: <short name of the work>

A one-line summary of what these tasks build. Reference the source spec if there is one.

Work the **frontier**: any task whose blockers are all done. For a purely linear chain that means top to bottom.

## <Task title>

**What to build:** the end-to-end behaviour this task makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the titles of the tasks that gate this one, or "None — can start immediately".

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

## <Task title>

...

</tasks-file-template>

In any form, avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

Work the frontier one task at a time with `/implement`, clearing context between tasks when useful.
