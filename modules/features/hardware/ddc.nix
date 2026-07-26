_: {
  flake.modules.nixos.ddc = {
    config,
    pkgs,
    ...
  }: {
    boot = {
      extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
      kernelModules = ["i2c-dev" "ddcci_backlight"];
    };

    environment.systemPackages = [pkgs.ddcutil];

    security.sudo.extraRules = [
      {
        groups = ["wheel"];
        commands = [
          {
            command = "/run/current-system/sw/bin/ddcutil";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
