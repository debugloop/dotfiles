{ ... }: {
  flake.modules.home.common_network = {pkgs, ...}: {
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
