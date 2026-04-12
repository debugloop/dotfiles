{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    config,
    ...
  }: let
    agenixPackage = inputs.agenix.packages.${system}.default;

    allKeys =
      map pkgs.lib.fileContents
      (pkgs.lib.filesystem.listFilesRecursive (inputs.self + "/keys/auth")
        ++ pkgs.lib.filesystem.listFilesRecursive (inputs.self + "/keys/hosts"));

    fido2Recipient = "age1l9vzn3un0j7kta9x388ttsheq8dq6c9954lpqee5pmaeh4xgr5aszy7xn3";

    secretsNix = pkgs.writeText "secrets.nix" ''
      let
        all = [
          ${pkgs.lib.concatMapStringsSep "\n  " (k: ''"${pkgs.lib.trim k}"'') allKeys}
        ];
        fido2 = [ "${fido2Recipient}" ];
      in
      {
        "secrets/password.age".publicKeys = all;
        "secrets/restic_password.age".publicKeys = all;
        "secrets/tailscale.age".publicKeys = all;
        "secrets/grafana.age".publicKeys = all;
        "secrets/miniflux.age".publicKeys = all;
        "secrets/mullvad.conf.age".publicKeys = all;
        "secrets/woodpecker.age".publicKeys = all;
        "secrets/hetzner_infra.age".publicKeys = all;
        "secrets/hetzner_tfstate_passphrase.age".publicKeys = fido2;
      }
    '';

    agenixWrapped = pkgs.writeShellScriptBin "agenix" ''
      export RULES="${secretsNix}"

      if [ "$USER" = "root" ]; then
        identity_file="/etc/ssh/ssh_host_ed25519_key"
      else
        identity_file="''${HOME}/.ssh/id_ed25519"
      fi

      ${agenixPackage}/bin/agenix -i "$identity_file" "$@"

      if [ -n "$SUDO_USER" ]; then
        chown -R "$SUDO_USER:" secrets/ 2>/dev/null || true
      fi
    '';
  in {
    devShells.default = pkgs.mkShell {
      shellHook = config.pre-commit.installationScript;
      inputsFrom = [config.pre-commit.devShell];
      packages = [
        agenixWrapped
        pkgs.age-plugin-fido2-hmac
      ];
    };
  };
}
