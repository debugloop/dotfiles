# Deepening Modules

Use this guide when you deepen modules that have dependencies. The dependency type determines the seam and test strategy.

## Dependency types

### In-process

Pure computation and in-memory state need no adapter. Merge shallow modules and test through the new interface.

### Local substitute

Some dependencies have a local stand-in, such as an in-memory filesystem or PGLite. Keep this seam internal and run the stand-in in tests.

### Remote and owned

For an internal remote system, define a port at the seam. Use a production transport adapter and an in-memory test adapter.

The deep module owns the behavior. The adapter owns HTTP, gRPC, queue, or other transport details.

### External

For a third-party system, inject a narrow port. Production uses the external adapter. Tests use a focused adapter that implements the required behavior.

## Seam discipline

- Do not add a port only to make mocking easy.
- Make sure that the production and test adapters represent real behavioral variation.
- Keep internal seams out of the external interface.
- Put domain behavior in the deep module, not in transport adapters.

## Replace tests instead of layering them

1. Write tests at the deepened module's interface.
2. Assert observable outcomes, not internal state.
3. Remove old tests for shallow modules when the new tests cover the same behavior.
4. Keep tests that cover behavior outside the new interface.

A good test survives an internal refactor. If an implementation change breaks the test without changing behavior, the test crosses the wrong seam.
