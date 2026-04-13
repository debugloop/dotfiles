_: {
  flake.modules.nixos.bluetooth = {inputs, ...}: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;

    environment.persistence."/nix/persist".directories = [
      "/var/lib/bluetooth"
    ];

    home-manager.sharedModules = [inputs.self.modules.homeManager.bluetooth];
  };

  flake.modules.homeManager.bluetooth = _: {
    services.blueman-applet.enable = true;
  };
}
