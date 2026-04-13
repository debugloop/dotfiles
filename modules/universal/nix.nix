_: {
  flake.modules.nixos.nix = {
    programs.nh.enable = true;
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
