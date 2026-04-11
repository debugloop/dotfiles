{ ... }: {
  flake.modules.home.common_nix = {
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
