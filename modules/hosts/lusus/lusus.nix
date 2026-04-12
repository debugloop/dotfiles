{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.lusus = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      top = self;
    };
    modules = [self.nixosModules.lusus];
  };

  flake.nixosModules.lusus = {
    top,
    inputs,
    ...
  }: {
    imports =
      (with top.nixosModules; [laptop_host])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "lusus";

    home-manager.users.danieln = {
      home.stateVersion = "22.11";
      imports = with top.homeModules;
        [
          danieln
          laptop_ai
          laptop_applications
          laptop_clipman
          laptop_ghostty
          laptop_kanshi
          laptop_kitty
          laptop_mako
          laptop_osd
          laptop_swayidle
          laptop_waybar
          laptop_wl_kbptr
        ]
        ++ [inputs.gridx.home-module];
    };

    system.stateVersion = "22.11";
  };
}
