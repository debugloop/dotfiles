_: {
  flake.modules.nixos.tailscale = {
    config,
    inputs,
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

    environment.systemPackages = [config.services.tailscale.package];

    networking.firewall = {
      trustedInterfaces = [
        "tailscale0"
      ];
    };

    age.secrets = {
      tailscaleAuthkey.file = inputs.self + "/secrets/tailscale.age";
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/tailscale"
      ];
    };
  };
}
