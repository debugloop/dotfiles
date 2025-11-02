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
}
