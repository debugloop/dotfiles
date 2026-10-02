_: {
  flake.modules.nixos.bluetooth = {
    config,
    inputs,
    ...
  }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;

    environment.persistence."/nix/persist".directories = [
      "/var/lib/bluetooth"
    ];

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.bluetooth];
  };

  flake.modules.homeManager.bluetooth = {
    dconf.settings."org/blueman/general"."plugin-list" = ["!StatusIcon"];
  };
}
