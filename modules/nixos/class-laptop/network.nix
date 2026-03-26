{lib, ...}: {
  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [];
    logLevel = "INFO";
    wifi = {
      # backend = "iwd";
    };
  };

  services = {
    avahi.enable = true;
    mullvad-vpn.enable = true;
  };

  environment.persistence."/nix/persist".directories = [
    "/etc/NetworkManager/system-connections"
    "/etc/mullvad-vpn"
  ];
}
