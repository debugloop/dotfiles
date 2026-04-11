{ ... }: {
  flake.modules.nixos.common_network = {
    hostName,
    ...
  }: {
    networking = {
      hostName = hostName;
      firewall.enable = true;
      nftables.enable = true;
    };

    services.resolved.enable = true;
  };
}
