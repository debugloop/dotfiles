_: {
  mkHetznerEnv = statePrefix: ''
    export TF_VAR_hcloud_token="$(cat /run/agenix/hetzner_token)"
    export TF_VAR_storage_box_id="$(cat /run/agenix/hetzner_storagebox_id)"
    export TF_HTTP_USERNAME="$(cat /run/agenix/hetzner_storagebox_tfstate_user)"
    export TF_HTTP_ADDRESS="https://$(cat /run/agenix/hetzner_storagebox_tfstate_user).your-storagebox.de/${statePrefix}-terraform.tfstate"
    export TF_HTTP_PASSWORD="$(cat /run/agenix/hetzner_storagebox_tfstate_password)"
    export TF_HTTP_UPDATE_METHOD="PUT"
    export TF_HTTP_LOCK_METHOD="PUT"
    export TF_HTTP_UNLOCK_METHOD="DELETE"
  '';

  mkAgenixRules = {
    pkgs,
    repoRoot,
  }: let
    inherit (pkgs) lib;

    authPubKeys =
      map lib.fileContents
      (lib.filter (lib.hasSuffix ".pub")
        (lib.filesystem.listFilesRecursive "${repoRoot}/keys/auth"));
    authPubKeysUnique = lib.unique (map lib.trim authPubKeys);

    hostKeys = lib.listToAttrs (map (path: let
        name = builtins.unsafeDiscardStringContext (lib.removeSuffix ".pub" (baseNameOf path));
      in {
        inherit name;
        value = lib.fileContents path;
      })
      (lib.filter (lib.hasSuffix ".pub")
        (lib.filesystem.listFilesRecursive "${repoRoot}/keys/hosts")));

    mkStorageBoxEntries =
      lib.mapAttrsToList (hostName: hostKey: let
        hostKeyTrim = lib.trim hostKey;
        others = lib.filter (k: k != hostKeyTrim) authPubKeysUnique;
      in ''
        "secrets/storagebox-${hostName}.age".publicKeys = [
          "${hostKeyTrim}"
        ] ++ [
          ${lib.concatMapStringsSep "\n      " (k: ''"${k}"'') others}
        ];
      '')
      hostKeys;
  in
    pkgs.writeText "secrets.nix" ''
      let
        all = [
          ${lib.concatMapStringsSep "\n  " (k: ''"${k}"'') authPubKeysUnique}
        ];
      in
      {
        "secrets/password.age".publicKeys = all;
        "secrets/restic_password.age".publicKeys = all;
        "secrets/tailscale.age".publicKeys = all;
        "secrets/grafana.age".publicKeys = all;
        "secrets/gh-token.age".publicKeys = all;
        "secrets/miniflux.age".publicKeys = all;
        "secrets/factorio.age".publicKeys = all;
        "secrets/mullvad.conf.age".publicKeys = all;
        "secrets/woodpecker.age".publicKeys = all;
        "secrets/hetzner_token.age".publicKeys = all;
        "secrets/hetzner_storagebox_tfstate_user.age".publicKeys = all;
        "secrets/hetzner_storagebox_tfstate_password.age".publicKeys = all;
        "secrets/hetzner_storagebox_id.age".publicKeys = all;

        ${lib.concatStrings mkStorageBoxEntries}
      }
    '';
}
