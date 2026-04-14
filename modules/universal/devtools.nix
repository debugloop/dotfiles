_: {
  flake.modules.nixos.devtools = {config, ...}: {
    environment.persistence."/nix/persist".users.${config.mainUser} = {
      directories = [
        {
          directory = ".gnupg";
          mode = "0700";
        }
        ".local/share/posting"
      ];
      files = [".netrc"];
    };
  };

  flake.modules.homeManager.devtools = {pkgs, ...}: {
    home = {
      file = {
        ".ignore".text = ''
          vendor/
          go.mod
          go.sum
        '';
        ".sqliterc".text = ''
          .mode column
          .headers on
          .separator ROW "\n"
          .nullvalue NULL
        '';
      };
      packages = with pkgs; [
        # general dev tools
        ast-grep
        curl
        gnumake
        gnupg
        ijq
        jq
        jupyter
        jwt-cli
        mermaid-cli
        pgcli
        posting
        prettier
        redis
        rr
        socat
        sqlite
        tokei
        yq-go

        # writing / linting
        codespell
        harper
        proselint
        typos
        vale
        yamllint
      ];
    };
  };
}
