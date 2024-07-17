{
  pkgs,
  config,
  ...
}: {
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthkey.path;
    openFirewall = true;
    useRoutingFeatures = "client";
  };

  environment.systemPackages = [pkgs.tailscale];

  networking.firewall = {
    trustedInterfaces = [
      "tailscale0"
    ];
  };

  age = {
    identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      tailscaleAuthkey.file = ../../secrets/tailscale.age;
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
