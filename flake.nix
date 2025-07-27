{
  description = "debugloop/dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";

    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    helix.url = "github:helix-editor/helix";

    # niri-unstable = {
    #   url = "github:YaLTeR/niri/a11fe23cbf6ba01ae4c23679aa2f7d7d8b44baf4";
    #   flake = false;
    # };
    niri = {
      url = "github:sodiboo/niri-flake";
      # inputs.niri-unstable.follows = "niri-unstable";
    };

    # private flakes
    gridx.url = "git+ssh://git@github.com/debugloop/gridx";
    # gridx.url = "path:/home/danieln/code/gridx";
  };

  outputs = inputs: inputs.blueprint {inherit inputs;};
}
