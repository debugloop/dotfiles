_: {
  flake.nixosModules.bluetooth = {top, ...}: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;

    environment.persistence."/nix/persist".directories = [
      "/var/lib/bluetooth"
    ];

    home-manager.sharedModules = [top.homeModules.bluetooth];
  };

  flake.homeModules.bluetooth = _: {
    services.blueman-applet.enable = true;
  };
}
