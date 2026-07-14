---
name: implement
description: Implement a tightly scoped piece of work from the current conversation, an explicit request, or a spec file.
disable-model-invocation: true
---

# Implement

Implement the work described by the user in the current conversation, a directly supplied request, or an explicit spec file.

This repo does **not** use an agent-managed issue tracker as the default work-packaging layer. The human owns the roadmap and long-term work selection; the agent owns one tightly scoped task at a time.

## Process

1. Restate the narrow task you are about to implement. If the scope is ambiguous or larger than one agent-sized batch, stop and ask the user to narrow it.
2. Read the relevant domain docs (`CONTEXT.md`, `CONTEXT-MAP.md`, ADRs) when they exist, so names and decisions match the repo.
3. Use `/tdd` where possible, at pre-agreed seams.
4. Run typechecking regularly, single test files regularly, and the full relevant test suite once at the end.
5. Once done, use `/code-review` to review the work when the user wants a review pass.

## Work packaging

- Do **not** create issues, triage labels, queues, or tracker state.
- Use `.scratch/` only for temporary notes/specs when the user asks for a durable artifact or the task genuinely needs one.
- If the task naturally breaks into several small steps, keep the checklist in the response or use `/to-tasks`; do not turn it into a ticket system.

Do **not** commit. Leave changes staged or unstaged for the user to inspect.

If multiple commits would be advantageous, stop and explain the proposed split. Before doing any commit-oriented work, create a new branch from a clean slate: stash or otherwise clear unrelated work first, then branch. Never commit on `main`.
