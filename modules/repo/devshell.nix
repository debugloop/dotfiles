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
        ++ pkgs.lib.filesystem.listFilesRecursive (inputs.self + "/keys/hosts"))
      ++ personalRecipients;

    personalRecipients = [
      "age1l9vzn3un0j7kta9x388ttsheq8dq6c9954lpqee5pmaeh4xgr5aszy7xn3"
      "age1yygc894kqf06fez8vjlgndzugk4gmd4w5vvlx2wxtg2cve3klgxq978046"
    ];

    personalTailscaleKeys =
      map pkgs.lib.fileContents [
        (inputs.self + "/keys/hosts/roshar.pub")
        (inputs.self + "/keys/hosts/simmons.pub")
      ]
      ++ personalRecipients;

    secretsNix = pkgs.writeText "secrets.nix" ''
      let
        all = [
          ${pkgs.lib.concatMapStringsSep "\n  " (k: ''"${pkgs.lib.trim k}"'') allKeys}
        ];
        personal = [
          ${pkgs.lib.concatMapStringsSep "\n  " (k: ''"${k}"'') personalRecipients}
        ];
        personalTailscale = [
          ${pkgs.lib.concatMapStringsSep "\n  " (k: ''"${pkgs.lib.trim k}"'') personalTailscaleKeys}
        ];
      in
      {
        "secrets/login_password_hash.age".publicKeys = all;
        "secrets/restic_password.age".publicKeys = all;
        "secrets/tailscale.age".publicKeys = personalTailscale;
        "secrets/grafana.age".publicKeys = all;
        "secrets/hister.age".publicKeys = all;
        "secrets/miniflux.age".publicKeys = all;
        "secrets/mullvad.conf.age".publicKeys = all;
        "secrets/woodpecker.age".publicKeys = all;
        "secrets/nix-ci-netrc.age".publicKeys = all;
        "secrets/hetzner_infra.age".publicKeys = personal;
        "secrets/wall.age".publicKeys = all;
        "secrets/luks.age".publicKeys = personal;
        "secrets/hetzner_tfstate_passphrase.age".publicKeys = personal;
      }
    '';

    agenixWrapped = pkgs.writeShellScriptBin "agenix" ''
      export RULES="${secretsNix}"
      export PATH="${pkgs.age-plugin-fido2-hmac}/bin:$PATH"

      if [ "$USER" = "root" ]; then
        identity_file="/etc/ssh/ssh_host_ed25519_key"
      else
        identity_file="''${HOME}/.ssh/id_ed25519"
      fi

      identities=(
        -i "$identity_file"
        -i "${inputs.self}/keys/physical/desk.pub"
        -i "${inputs.self}/keys/physical/keychain.pub"
      )
      for arg in "$@"; do
        if [[ "$arg" == "-i" || "$arg" == "--identity" ]]; then
          identities=()
          break
        fi
      done

      result=0
      ${agenixPackage}/bin/agenix "''${identities[@]}" "$@" || result=$?

      if [ -n "$SUDO_USER" ]; then
        chown -R "$SUDO_USER:" secrets/ 2>/dev/null || true
      fi
      exit "$result"
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
