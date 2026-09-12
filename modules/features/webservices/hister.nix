_: {
  flake.modules.nixos.hister = {config, ...}: let
    cfg = config.services.hister;
  in {
    services.hister = {
      enable = true;
      dataDir = "/var/lib/hister";
      settings.server.address = "127.0.0.1:4433";
    };

    environment.persistence."/nix/persist".directories = [
      {
        directory = cfg.dataDir;
        inherit (cfg) user group;
        mode = "0750";
      }
    ];

    systemd.services.hister.unitConfig.RequiresMountsFor = [cfg.dataDir];
  };
}
