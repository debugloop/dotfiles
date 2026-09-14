---
name: code-review
description: Review changes since a fixed point along two separate axes. Standards checks repository rules. Spec checks the user's request or explicit spec. Use for branch, PR, or work-in-progress reviews.
---

# Review

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the user's request, PRD, or explicit spec?

Run the axes as two separate passes. Complete the first report before the second pass. Keep their evidence and conclusions separate where possible.

This repo does **not** use an agent-managed issue tracker by default. Prefer an explicit spec path, PRD file, or conversation context over issue lookup.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before you continue, make sure that the fixed point resolves with `git rev-parse <fixed-point>`. Stop if the reference is invalid or the diff is empty.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. A path the user passed as an argument.
2. A PRD/spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
3. Issue or PR references in commit messages only when they are directly fetchable from the repo's normal tooling (for example `gh` in a GitHub repo) or the user asks you to fetch them.
4. If nothing is found, ask the user where the spec is. If no spec exists, skip the Spec pass and report "no spec available."

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below — a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation — and, like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Run two separate passes

Use the same diff and commit list for both passes. This harness does not supply isolated sub-agents, so do not claim that the passes are independent.

**Standards pass**

1. Read the standards sources and the full diff.
2. Report each documented-standard violation by file and hunk.
3. Cite the standards file and rule.
4. Report baseline smells separately and label them as judgment calls.
5. Skip checks that automated tooling already enforces.
6. Save this report before you start the Spec pass.

**Spec pass**

1. Read the spec and diff again. Do not treat conclusions from the Standards pass as Spec evidence.
2. Report missing or partial requirements.
3. Report behavior that the spec did not request.
4. Report implementations that appear to contradict a requirement.
5. Quote the relevant spec text for each finding.

If no spec exists, skip this pass and state that no spec was available.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings — the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes — that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the request/spec asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
