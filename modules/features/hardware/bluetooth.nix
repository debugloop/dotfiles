_: {
  flake.modules.nixos.bluetooth = _: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;

    environment.persistence."/nix/persist".directories = [
      "/var/lib/bluetooth"
    ];
  };
}
