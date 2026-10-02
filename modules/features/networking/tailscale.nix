_: {
  flake.modules.nixos.tailscale = {config, ...}: {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client";
    };

    environment.systemPackages = [config.services.tailscale.package];

    environment.persistence."/nix/persist".directories = [
      "/var/lib/tailscale"
    ];
  };
}
