{
  description = "debugloop/dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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

    niri-autoselect-portal = {
      url = "git+https://codeberg.org/debugloop/niri-autoselect-portal.git";
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = import ./lib/import-tree.nix ./modules;

      systems = ["x86_64-linux"];

      perSystem = {pkgs, ...}: {
        packages = {
          host-keygen = import ./packages/host-keygen.nix {inherit pkgs;};
          nvim = import ./packages/nvim.nix {inherit pkgs;};
          install = import ./packages/install.nix {inherit pkgs inputs;};
        };

        treefmt = {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
        };
      };
    });
}
