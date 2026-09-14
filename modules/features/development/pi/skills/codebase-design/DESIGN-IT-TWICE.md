# Design It Three Ways

Use this process when the interface for a module is uncertain. It preserves the intent of "Design It Twice" without requiring sub-agents.

## 1. Frame the problem

Write down:

- the behavior that the module must hide
- the constraints that every interface must satisfy
- the dependency types from [DEEPENING.md](DEEPENING.md)
- the domain terms that the interface must use
- a small code sketch that shows the problem, not a proposed solution

Show this frame to the user before you design the interfaces.

## 2. Produce three separate designs

Complete each design before you start the next one. Do not compare or combine them yet.

### Design A: minimum interface

Use one to three entry points. Maximize leverage per entry point.

### Design B: common caller

Make the most frequent caller simple. Let uncommon callers accept more setup when necessary.

### Design C: explicit variation

Optimize for the variations that already exist. Do not add extension points for hypothetical requirements.

Add a fourth ports-and-adapters design only when a remote dependency creates a real seam.

For each design, give:

1. The complete interface, including invariants, ordering, errors, and performance constraints.
2. A caller example.
3. The behavior hidden by the module.
4. The dependency and adapter strategy.
5. The trade-offs in depth, locality, and seam placement.

## 3. Compare after all designs exist

Present the designs separately. Then compare them by:

- interface size
- depth and caller leverage
- locality of changes and defects
- seam placement
- required adapters
- test surface

Recommend one design. A hybrid is acceptable only after the comparison shows which parts combine without enlarging the interface unnecessarily.
