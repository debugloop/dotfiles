# Secret management

## 1. Configuration

Agenix decrypts runtime secrets with each host's persistent SSH key.
Agenix-rekey encrypts the source secrets for both FIDO2 keys in
`keys/physical/`. It then creates deployment ciphertext for each host that
has a `rekeyFile` declaration.

Each host sets `age.rekey.hostPubkey` from its public-key file in
`keys/hosts/`. The public key must match the persistent private key on that
host.

The local storage mode saves deployment ciphertext in
`secrets/rekeyed/<host>/`. Add these encrypted files to Git before a build.
A clean checkout can then build without a hardware key.

The work-flake secrets still use conventional agenix declarations.
The infrastructure and LUKS scripts decrypt their source secrets directly.
They do not use deployment ciphertext.

## 2. Initial migration

Wait for the current system build to finish. Connect the desk FIDO2 key.
Run these commands as your normal user from `/etc/nixos`:

```sh
cd /etc/nixos
env TMPDIR="$XDG_RUNTIME_DIR" nix run .#agenix -- update-masterkeys
nix run .#agenix -- rekey
```

`update-masterkeys` preserves the bytes of each declared source secret.
It replaces the recipients with the configured master recipients.
It does not rotate credentials or change ciphertext in Git history.
It does not include unused secrets or secrets from another repository.

`rekey` creates the ciphertext for delos, simmons, and roshar.
If decryption fails, retry with the correct key or abort.
Do not select a dummy replacement.

Add the generated ciphertext to Git:

```sh
git add secrets/rekeyed/delos/*.age \
  secrets/rekeyed/simmons/*.age \
  secrets/rekeyed/roshar/*.age
nix eval --json .#checks.x86_64-linux \
  --option allow-import-from-derivation false \
  --apply 'builtins.mapAttrs (_: check: check.drvPath)' > /dev/null
nix flake check --no-build --option allow-import-from-derivation false
```

Normal evaluation registers the copied secret directories in the Nix store.
On Nix 2.34.8, the read-only `--no-build` check can fail before that step.
The error reports an invalid store path, not a decryption failure.
Run both evaluation commands after a secret change. Neither command builds
a system.

The Nix commands can build the small management tools.
They do not build a system until you run the activation command.

Compare the public-key fingerprints before activation:

```sh
sudo ssh-keygen -lf /nix/persist/etc/ssh/ssh_host_ed25519_key.pub
ssh-keygen -lf keys/hosts/delos.pub
```

The fingerprints must match. If they differ, update the tracked public key
and run `rekey` again before activation.

Apply the delos configuration without a reboot:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#delos
```

Report the result and authorize system builds and runtime checks.
After those checks, review the migration and complete any remaining cleanup.
Apply the final configuration again. Reboot only after that assessment.

## 3. Routine changes

Edit a source secret with the upstream CLI:

```sh
agenix edit secrets/example.age
agenix rekey
```

The CLI is available globally after activation and in the repository's
development shell. Before activation, use `nix run .#agenix --`.
The work repository keeps its own development-shell command until its
migration.

Add new deployment ciphertext to Git before a build.
If rekeying removes obsolete ciphertext, stage those deletions too.
You can use `agenix rekey -a` to stage only the generated host directories.

After a host-key change, rekey before installation or activation.
Keep the existing StorageBox key-update procedure.

## 4. Installation

1. Generate the host key with `host-keygen`.
2. Add the public key to Git and set the host's `age.rekey.hostPubkey`.
3. Run `agenix rekey` and add the deployment ciphertext to Git.
4. Install the system with the matching private key preseeded.

The installer deletes the temporary private key only after a successful
installation. No post-installation rekey step is required.
