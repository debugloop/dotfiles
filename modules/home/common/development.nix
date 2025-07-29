{pkgs, ...}: {
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
      dyff
      entr
      fd
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
      gotools
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
      nodePackages_latest.prettier
      nodePackages_latest.yaml-language-server
      pgcli
      posting
      proselint
      protobuf
      redis
      ripgrep
      rr
      socat
      sqlite
      stylua
      tcpdump
      tokei
      tree-sitter
      typescript
      typescript-language-server
      typos
      typos-lsp
      vale
      yamllint
      yq-go
    ];
  };
}
