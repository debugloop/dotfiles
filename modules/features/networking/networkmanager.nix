_: {
  flake.modules.nixos.networkmanager = {lib, ...}: {
    networking.networkmanager = {
      enable = true;
      plugins = lib.mkForce [];
      logLevel = "INFO";
      wifi = {
        # backend = "iwd";
      };
    };

    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
      };
      resolved.settings.Resolve.MulticastDNS = "no";
    };

    environment.persistence."/nix/persist".directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
