_: {
  flake.modules.nixos.nix = {config, ...}: {
    nix.settings = {
      experimental-features = "nix-command flakes";
      trusted-users = ["@wheel"];
    };

    programs.nh.enable = true;

    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".local/share/direnv"
      ".local/share/nix"
    ];
  };

  flake.modules.homeManager.nix = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [inputs.nix-index-database.homeModules.nix-index];

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
