_: {
  flake.modules.nixos.nix = {inputs, ...}: {
    imports = [inputs.agenix.nixosModules.default];

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = ["@wheel"];
      };
    };

    programs.nh.enable = true;

    nixpkgs = {
      hostPlatform = "x86_64-linux";
      config = {
        allowUnfree = true;
        warnUndeclaredOptions = true;
      };
      overlays = [
        # inputs.neovim-nightly-overlay.overlays.default
      ];
    };

    age.secrets = {
      password.file = ../../secrets/password.age;
    };
  };

  flake.modules.homeManager.nix = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [inputs.nix-index-database.homeModules.nix-index];

    age.identityPaths = ["/home/danieln/.ssh/agenix"];

    home = {
      sessionVariables = {
        FLAKE = "/etc/nixos";
      };
      packages = with pkgs; [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        age
        alejandra
        comma
        nix-tree
        nixd
        nvd
      ];
    };

    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      home-manager.enable = true;
      nh = {
        enable = true;
        flake = "/etc/nixos";
      };
    };
  };
}
