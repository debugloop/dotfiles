{
  pkgs,
  inputs,
  ...
}: {
  home = {
    sessionVariables = {
      FLAKE = "/etc/nixos";
    };
    packages = with pkgs; [
      inputs.agenix.packages.${pkgs.system}.default
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
}
