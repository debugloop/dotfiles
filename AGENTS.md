# Repository Architecture

## Module System

This flake uses [flake-parts](https://flake.parts) as its module framework. The
entry point is `flake.nix`, which calls `mkFlake` and imports everything under
`modules/` via `lib/import-tree.nix` — a recursive directory importer that
auto-discovers all `.nix` files while skipping `_`-prefixed filenames (private
helpers imported explicitly by their parent).

The module tree separates features, reusable policy profiles, concrete hosts,
and repository tooling:

| Directory | Purpose |
| --- | --- |
| `modules/features/` | Leaf modules grouped by concern: CLI, desktop, development, hardware, networking, storage, system, users, virtualisation, and webservices |
| `modules/profiles/` | Shallow shared policy bundles: `profile_base`, `profile_client`, `profile_development`, `profile_server`, and `profile_user_base` |
| `modules/hosts/` | Per-host NixOS configurations (`<host>/<host>.nix` plus optional `_hardware-configuration.nix`) |
| `modules/repo/` | Flake-level concerns: devshell, treefmt, packages, infrastructure, checks, and linting |

## Composition Pattern

Each feature file normally defines a `flake.modules.nixos.<name>` or
`flake.modules.homeManager.<name>`. Repository modules define flake outputs or
`perSystem` configuration. Module names use underscores and normally match the
filename without `.nix`.

Concrete hosts import profiles directly and then list host-specific features:

```nix
# Simplified modules/hosts/roshar/roshar.nix
imports = with inputs.self.modules.nixos; [
  profile_base
  profile_server

  hetzner
  basicauth
  caddy
  grafana
];
```

Profiles are independent bundles and never import one another. Client hosts
import `profile_base`, `profile_client`, and `profile_development`; the server
imports only `profile_base` and `profile_server`. This keeps development tools
off the server without introducing hidden profile inheritance.

Modules reference one another through `inputs.self`, which is available through
`specialArgs` in NixOS modules and `extraSpecialArgs` in Home Manager modules.

## User and Home Manager Profiles

User integration lives under `modules/features/users/`:

- `account.nix` defines the NixOS account and attaches the baseline HM profile.
- `dotfiles.nix` defines the mutable checkout path used by out-of-store links.
- `generic_linux.nix` exposes `homeConfigurations.danieln` and the first-install
  `nix run .#home` activation app for non-NixOS Linux.

`modules/profiles/profile_user_base.nix` composes the common Home Manager
leaves. NixOS client/server profiles attach their matching HM profiles to the main user.
The generic Linux configuration uses `profile_user_base` and
`profile_development`, and overrides `dotfiles.root` to
`~/.config/dotfiles`; NixOS keeps the `/etc/nixos` default.

## Cross-referencing

- NixOS modules reference one another via `inputs.self.modules.nixos.<name>`.
- Home Manager modules reference one another via
  `inputs.self.modules.homeManager.<name>`.
- Profiles use a `profile_` prefix in both registries.
- Private helper files such as `_hardware-configuration.nix`, `_plugins.nix`,
  and StorageBox account files are imported explicitly and never auto-imported.
- Relative assets stay beside their owning leaf and move with it.

# Design Principles

1. **Leaf-centric features** — Feature modules should be self-contained and
   focused on one concern. Composition belongs in profiles, user integration,
   and concrete hosts.

2. **Single responsibility** — Avoid bundling unrelated settings. A file may
   provide matching NixOS and HM halves when they represent the same feature.

3. **No hidden host dispatch** — Leaves should not select configuration by
   hostname. Hosts explicitly provide account data, provider modules, and
   workload-specific values.

4. **Feature-domain organization** — Organize leaves by what they do rather
   than where they happen to run. Applicability is expressed by profile and host
   imports.

5. **Shallow profiles** — Profiles are useful shared policy bundles, not an
   inheritance hierarchy. Hosts import base, role, and development profiles
   independently.

6. **Explicit exceptions and workloads** — Provider-specific features and
   optional workloads belong in concrete host imports rather than broad
   profiles.

7. **Canonical flake-parts idioms** — Publish reusable modules through
   `flake.modules.nixos.*` and `flake.modules.homeManager.*` via
   `flakeModules.modules`.

8. **Pure mutable-checkout paths** — Out-of-store links use the explicit
   `dotfiles.root` HM option. Do not infer a checkout from `PWD` or require
   impure evaluation.

# After Finishing a Series of Edits

- Run `statix` with automatic fixing, and then fix any remainders manually.
- Run `deadnix` with automatic fixing.
- Run `nix fmt`; it will format the tree.
- Before presenting solutions, add newly created files to Git individually or
  by an explicit path (never `git add .` or `git add -A`) and run
  `nix flake check`. It should pass cleanly. Warnings may be pre-existing, but
  assess whether they are related to the changes.
- When running on `simmons`, use `nvd diff` to compare the running system
  closure with the new build result and assess the changes.

# Backlog

## Features

### Rotate Grafana `secret_key`

**File:** `modules/features/webservices/grafana.nix:13`

```nix
secret_key = "SW2YcwTIb9zpOOhoPsMm"; # previous hardcoded default, rotate for multiuser env
```

This is the old Grafana default key, left in place during the hyperion→roshar
migration to avoid invalidating existing sessions. Once fully on roshar:

1. Generate a new random key.
2. Store it as an age secret, for example `secrets/grafana_secret_key.age`.
3. Reference it through `$__file{...}` using a new `age.secrets` entry.

## Repository Structure

Reference material:
[dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts),
[dendritic motivation](https://dendritic.oeiuwq.com/motivation/).

### Reconsider factories when the repository grows

The user account and generic HM output currently hardcode `danieln`, and host
configuration is explicit. This is preferable for the current one-user,
three-host setup. Reconsider user or host factories only when a second user or
substantial host repetition creates a concrete need; do not add factories only
to anticipate possible growth.
