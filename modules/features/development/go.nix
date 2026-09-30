_: {
  flake.modules.nixos.go = {config, ...}: {
    backup.exclude = ["home/${config.mainUser}/go"];

    environment.persistence."/nix/persist".users.${config.mainUser}.directories = ["go"];
  };

  flake.modules.homeManager.go = {
    lib,
    pkgs,
    ...
  }: {
    programs.go.enable = true;

    home = {
      sessionPath = [
        "$HOME/go/bin"
      ];
      packages = with pkgs; [
        delve
        go-tools
        gofumpt
        goimports-reviser
        golangci-lint
        gopls
        gotags
        gotest
        gotests
        gotestsum
        (lib.lowPrio pkgs.gotools)
      ];
    };
  };
}
