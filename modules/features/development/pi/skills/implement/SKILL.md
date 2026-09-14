---
name: implement
description: Implement a tightly scoped piece of work from the current conversation, an explicit request, or a spec file.
disable-model-invocation: true
---

# Implement

Implement the work described by the user in the current conversation, a directly supplied request, or an explicit spec file.

This repo does **not** use an agent-managed issue tracker as the default work-packaging layer. The human owns the roadmap and long-term work selection; the agent owns one tightly scoped task at a time.

## Process

1. Restate the narrow task you are about to implement. If the scope is ambiguous or too large for one context window, ask the user to narrow it.
2. Read the relevant domain documents when they exist. Use their names and decisions.
3. State the test risk as `required`, `recommended`, or `not needed`, with one reason. Identify an existing test seam when a test is required or recommended.
4. If the user requested test-first work, load the `tdd` skill and agree on the test seams.
5. Run focused type checks and tests during the work. Run the full relevant checks once at the end.
6. If the user requests a review, load the `code-review` skill after implementation.

## Work packaging

- Do **not** create issues, triage labels, queues, or tracker state.
- Use `.scratch/` only for temporary notes/specs when the user asks for a durable artifact or the task genuinely needs one.
- If the task needs several small steps, keep a short checklist in the response. Do not start a separate planning workflow automatically.

Do **not** commit. Leave changes staged or unstaged for the user to inspect.

If multiple commits would be advantageous, stop and explain the proposed split. Before doing any commit-oriented work, create a new branch from a clean slate: stash or otherwise clear unrelated work first, then branch. Never commit on `main`.
