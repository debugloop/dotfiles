_: {
  flake.modules.homeManager.languages = {pkgs, ...}: {
    home = {
      sessionVariables = {
        NODE_PATH = "${pkgs.typescript}/lib/node_modules";
      };
      packages = with pkgs; [
        # rust
        rust-analyzer
        cargo
        rustfmt
        rustc
        gcc

        # lua
        lua-language-server
        luajit
        stylua

        # protobuf / grpc
        buf
        protobuf
        grpcurl

        # typescript
        typescript
        typescript-language-server

        # language servers / linters for nix, yaml, fish
        nil
        fish-lsp
        yaml-language-server
        typos-lsp

        # parsers
        tree-sitter
      ];
    };
  };
}
