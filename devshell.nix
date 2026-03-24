{
  pkgs,
  inputs,
  perSystem,
  ...
}: let
  secretsNix = inputs.self.lib.mkAgenixRules {
    inherit pkgs;
    repoRoot = ./.;
  };

  agenixWrapped = pkgs.writeShellScriptBin "agenix" ''
    export RULES="${secretsNix}"

    if [ "$USER" = "root" ]; then
      identity_file="/etc/ssh/ssh_host_ed25519_key"
    else
      identity_file="''${HOME}/.ssh/id_ed25519"
    fi

    ${perSystem.agenix.default}/bin/agenix -i "$identity_file" "$@"

    if [ -n "$SUDO_USER" ]; then
      chown -R "$SUDO_USER:" secrets/ 2>/dev/null || true
    fi
  '';
in
  pkgs.mkShell {
    packages = [
      agenixWrapped
      pkgs.ssh-to-age
    ];
  }
