_: {
  flake.modules.nixos.go = {config, ...}: {
    environment.persistence."/nix/persist".users.${config.mainUser} = {
      directories = [
        {
          directory = ".gxctl";
          mode = "0700";
        }
        "go"
      ];
    };
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
