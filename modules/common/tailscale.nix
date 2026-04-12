{...}: {
  flake.nixosModules.common_tailscale = {
    pkgs,
    config,
    ...
  }: {
    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscaleAuthkey.path;
      authKeyParameters = {
        preauthorized = true;
        ephemeral = false;
      };
      extraUpFlags = ["--advertise-tags=tag:nix"];
      openFirewall = true;
      useRoutingFeatures = "client";
    };

    environment.systemPackages = [pkgs.tailscale];

    networking.firewall = {
      trustedInterfaces = [
        "tailscale0"
      ];
    };

    age.secrets = {
      tailscaleAuthkey.file = ../../secrets/tailscale.age;
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/tailscale"
      ];
    };
  };
}
