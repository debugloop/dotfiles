_: {
  flake.modules.nixos.nix = {
    config,
    lib,
    ...
  }: {
    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = ["@wheel"];
      };
    };

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
      config = {
        allowUnfree = true;
        warnUndeclaredOptions = true;
      };
    };

    programs.nh.enable = true;

    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".local/share/direnv"
      ".local/share/nix"
    ];
  };

  flake.modules.homeManager.nix = {
    config,
    pkgs,
    inputs,
    ...
  }: {
    home = {
      sessionVariables = {
        FLAKE = config.dotfiles.root;
      };
      packages = with pkgs; [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        age
        alejandra
        nix-tree
        nixd
        nvd
      ];
    };

    programs = {
      direnv = {
        enable = true;
        silent = true;
        nix-direnv.enable = true;
      };
      home-manager.enable = true;
      nh = {
        enable = true;
        flake = config.dotfiles.root;
      };
    };
  };
}
