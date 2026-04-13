_: {
  flake.nixosModules.networkmanager = {lib, ...}: {
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
      mullvad-vpn.enable = true;
      resolved.settings.Resolve.MulticastDNS = "no";
    };

    environment.persistence."/nix/persist".directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/mullvad-vpn"
    ];
  };
}
