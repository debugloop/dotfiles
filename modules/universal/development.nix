_: {
  flake.modules.nixos.development = {config, ...}: {
    environment.persistence."/nix/persist".users.${config.mainUser} = {
      directories = [
        {
          directory = ".gxctl";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
        "go"
        ".local/share/posting"
      ];
      files = [".netrc" ".kube/config"];
    };
  };

  flake.modules.homeManager.development = {
    pkgs,
    lib,
    ...
  }: {
    programs = {
      go = {
        enable = true;
      };
    };
    home = {
      sessionPath = [
        "$HOME/go/bin"
      ];
      sessionVariables = {
        NODE_PATH = "${pkgs.typescript}/lib/node_modules";
        KUBECTL_EXTERNAL_DIFF = "${pkgs.dyff}/bin/dyff between --omit-header --set-exit-code";
      };
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
        ast-grep
        buf
        codespell
        curl
        delve
        gnumake
        gnupg
        dyff
        fish-lsp
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
        grpcurl
        harper
        ijq
        jq
        jupyter
        jwt-cli
        k6
        kontemplate
        kubeconform
        kubectl
        kustomize
        lua-language-server
        luajit
        mermaid-cli
        nil
        pgcli
        prettier
        posting
        proselint
        protobuf
        redis
        rr
        rust-analyzer
        cargo
        gcc
        rustfmt
        rustc
        socat
        sqlite
        stylua
        tokei
        tree-sitter
        typescript
        typescript-language-server
        typos
        typos-lsp
        vale
        yamllint
        yaml-language-server
        yq-go
      ];
    };
  };
}
