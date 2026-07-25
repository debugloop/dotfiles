_: {
  flake.modules.nixos.network = _: {
    networking = {
      firewall.enable = true;
      nftables.enable = true;
    };

    programs = {
      mtr.enable = true;
      traceroute.enable = true;
    };

    services.resolved.enable = true;
  };

  flake.modules.homeManager.network = {pkgs, ...}: {
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
