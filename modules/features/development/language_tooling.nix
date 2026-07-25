_: {
  flake.modules.homeManager.language_tooling = {pkgs, ...}: {
    home = {
      sessionVariables = {
        NODE_PATH = "${pkgs.typescript}/lib/node_modules";
      };
      packages = with pkgs; [
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

        # language servers / linters for yaml, fish, typst
        fish-lsp
        yaml-language-server
        typos-lsp
        tinymist

        # parsers
        tree-sitter
      ];
    };
  };
}
