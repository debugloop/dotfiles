_: {
  flake.nixosModules.network = _: {
    networking = {
      firewall.enable = true;
      nftables.enable = true;
    };

    services.resolved.enable = true;
  };

  flake.homeModules.network = {pkgs, ...}: {
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
