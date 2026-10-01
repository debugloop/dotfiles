# LUKS unlock on simmons

## 1. Policy

The desk YubiKey requires a touch for the tested FIDO2 disk unlock method.
The enrollment policy does not require a PIN for later unlocks. Keep the existing
passphrase as an alternative. Keep the YubiKey at the desk if the laptop leaves.
Anyone with the laptop and YubiKey can unlock the disk.

The Nix configuration enables FIDO2 support in the systemd initrd. It waits up to
10 seconds for the key before it requests the passphrase. This timeout applies
to device discovery, not touch or PIN prompts.

Enrollment stores the credential and its authentication policy in the LUKS2
header, not the Nix configuration. These instructions do not change PAM, sudo,
login, or screen unlock. They do not change other credentials on the YubiKey.

The target is `/dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e`
(`/dev/nvme0n1p2`). Do not use the other LUKS partition.

## 2. Check recovery and save the header

Run these commands manually on `simmons`.

Check the existing passphrase in slot 0. This command does not create a mapping:

```sh
sudo cryptsetup open --test-passphrase --key-slot 0 --disable-external-tokens \
  /dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e
```

If the check fails, stop before enrollment.

Create a protected directory:

```sh
sudo install -d -m 0700 /root/luks-header-backups
```

Save the header before enrollment:

```sh
sudo cryptsetup luksHeaderBackup \
  /dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e \
  --header-backup-file /root/luks-header-backups/simmons-before-fido2.img
```

Copy this backup to secure storage outside the laptop before you continue.
Do not rely on `/root` to retain it after reboot. Do not commit it to Git.
A header backup permits access with the credentials valid when you created it,
even after you revoke those credentials in the current header.

## 3. Enroll the desk key

Use this section for initial enrollment only. If the FIDO2 token already exists,
continue with section 4. Do not repeat enrollment to fix a failed mapping test.

Connect only the desk YubiKey during enrollment. Check that systemd lists the
expected device:

```sh
systemd-cryptenroll --fido2-device=list
```

This command changes the LUKS header. It adds a keyslot and token without
removing the existing passphrase:

```sh
sudo systemd-cryptenroll \
  --fido2-device=auto \
  --fido2-with-client-pin=no \
  --fido2-with-user-presence=yes \
  --fido2-with-user-verification=no \
  /dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e
```

Enrollment can still request a touch or the existing FIDO2 PIN. These requests
are separate from the policy for later disk unlocks. Do not guess the PIN or
reset the key.

An earlier enrollment requested `--fido2-with-user-presence=no`. Systemd reported
that this key required user presence and enabled it. That request did not produce
unattended unlock. A touch request during unlock is therefore expected.

Inspect the result:

```sh
sudo cryptsetup luksDump \
  /dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e
```

Confirm that slot 0 remains and a `systemd-fido2` token references a new slot.

## 4. Test before reboot

Do not create another mapping of the live disk. The earlier
`systemd-cryptsetup attach` test failed because the device was already mapped.
Do not unmount or close `crypt` to test a credential.

Inspect the stored policy without printing the credential and salt:

```sh
sudo cryptsetup token export --token-id 0 \
  /dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e |
  jq 'del(."fido2-credential", ."fido2-salt")'
```

For the recorded enrollment, token 0 references slot 1. Expect
`fido2-up-required` to be `true`, and `fido2-clientPin-required` and
`fido2-uv-required` to be `false`. If the token ID changed, use the ID from
`cryptsetup luksDump` in both commands.

Check the token credential without creating a mapping:

```sh
sudo env LD_LIBRARY_PATH=/run/current-system/systemd/lib/cryptsetup \
  cryptsetup open --type luks2 --test-passphrase \
  --token-only --token-id 0 \
  /dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e &&
  printf 'FIDO2 credential verified\n'
```

Nixpkgs patches cryptsetup to load token plugins through the dynamic linker.
In this build, `--external-tokens-path` does not select the plugin directory.
The command sets `LD_LIBRARY_PATH` to the trusted systemd directory for this
process only. Set it after `sudo`, which filters loader variables from the
calling environment. Do not add writable directories to this path.

`--test-passphrase` checks the credential without device activation.
`--token-only` prevents fallback to the disk passphrase.

Touch the key when requested. Success prints `FIDO2 credential verified`.
Sudo can request a separate touch or password before cryptsetup starts.
If the test fails or requests a FIDO2 PIN, stop before reboot and inspect the
error and stored policy. A disposable-file test confirmed that the plugin loads
with this command. Authentication on the live disk still needs confirmation
with the enrolled key.

Disconnect the YubiKey. Repeat the credential test. It must fail without the key.
Repeat the slot 0 passphrase check from section 2. Reconnect the YubiKey.

## 5. Prepare and test boot

Install the prepared configuration for the next boot:

```sh
sudo nixos-rebuild boot --flake /etc/nixos#simmons
```

Reboot with the key connected. Touch the key when requested. Confirm that the
disk unlocks without a PIN or disk passphrase.

Test another boot without the key. Confirm that the passphrase works after the
device timeout. Keep the passphrase and header backup available during both tests.
The credential test does not test USB discovery in the initrd.

## 6. Revoke the disk credential

First, confirm that the slot 0 passphrase still works. To remove all FIDO2 disk
enrollments from this volume, run:

```sh
sudo systemd-cryptenroll --wipe-slot=fido2 \
  /dev/disk/by-uuid/4eb11486-bcd4-46aa-857c-ff6545dcd90e
```

This preserves the passphrase slot and does not reset the YubiKey. Remove the
FIDO2 crypttab options from `simmons.nix` to avoid the device wait on later boots.
Then install the updated boot configuration. Do not restore an old header merely
to revoke a credential.
