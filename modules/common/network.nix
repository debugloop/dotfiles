_: {
  flake.nixosModules.common_network = _: {
    networking = {
      firewall.enable = true;
      nftables.enable = true;
    };

    services.resolved.enable = true;
  };

  flake.homeModules.common_network = {pkgs, ...}: {
    home.packages = with pkgs; [
      dig
      netcat-openbsd
      openssh
      sshfs
      wget
      whois
    ];
  };
}
