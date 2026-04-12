_: {
  flake.nixosModules.laptop_bluetooth = {top, ...}: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;

    environment.persistence."/nix/persist".directories = [
      "/var/lib/bluetooth"
    ];

    home-manager.sharedModules = [top.homeModules.laptop_bluetooth];
  };

  flake.homeModules.laptop_bluetooth = _: {
    services.blueman-applet.enable = true;
  };
}
