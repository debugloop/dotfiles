---
name: codebase-design
description: Shared vocabulary for deep modules, interfaces, seams, adapters, and testability. Use when a module interface is unclear or another skill needs architecture guidance.
---

# Codebase Design

Design deep modules: put substantial behavior behind a small interface at a clear seam. Use the terms and principles in this skill when you design or restructure code.

## Vocabulary

Use these terms consistently. Do not substitute "component," "service," "API," or "boundary."

**Module**: an implementation and the interface that it gives to callers. A module can be a function, class, package, or vertical slice.

**Interface**: everything a caller must know. This includes types, invariants, ordering, errors, required configuration, and performance characteristics.

**Implementation**: the code inside a module. Use **adapter** instead when the role at a seam is important.

**Depth**: the behavior that callers get for the interface they must learn. A deep module gives high leverage through a small interface.

**Seam**: a place where behavior can change without an edit at that place. The seam location and the interface design are separate decisions.

**Adapter**: an implementation that satisfies an interface at a seam.

**Leverage**: the capability that callers get from a small interface.

**Locality**: the concentration of changes, defects, knowledge, and tests in one module.

## Principles

1. **Depth belongs to the interface.** Internal implementation size does not make a module deep.
2. **Use the deletion test.** If deletion spreads complexity across callers, the module earns its place.
3. **The interface is the test surface.** Callers and tests cross the same seam.
4. **Real seams need variation.** One adapter is hypothetical. Two adapters make the seam real.
5. **Keep internal seams private.** Do not expose a test seam through the external interface.

## Interface questions

- Can the module have fewer entry points?
- Can its parameters be simpler?
- Can it hide more ordering, configuration, or error-handling knowledge?
- Does the interface match the domain language?
- Can callers and tests observe the required behavior through the same seam?

## Relationships

- A module has one interface for its callers.
- Depth measures the leverage of that interface.
- A seam is the location of an interface.
- An adapter satisfies an interface at a seam.
- Depth gives leverage to callers and locality to maintainers.

## Further guidance

- Read [DEEPENING.md](DEEPENING.md) before you deepen modules with dependencies.
- Read [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md) when the interface itself is uncertain.
