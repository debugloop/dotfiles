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
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      age
      alejandra
      comma
      nix-tree
      nixd
      nvd
    ];
  };

  home.persistence."/nix/persist".directories = [
    ".local/share/direnv"
    ".local/share/nix"
  ];

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
