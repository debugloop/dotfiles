let
  hyperion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5AsSvmh0/jPzl4gDynYuPnI4yFkK9srbAxPsQgL/sE";
  simmons = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6PfN5CQE9VRocpilzDhhfaHfQwwC0mZkx4ndYTsS75";
  simmons-home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWBVbLoVONgH7omrP0wxWDD59jOv5n3V1PU9H2sA4Zp";
  lusus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIII2XSMk/4DoyRzSts/YeU8iN+eNDeRiNmfrHCmutcpQ";
  lusus-home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAqpPvRQGeHOvH1XRr0IPTLz2md6+L1Iz9e6e/S/UKJ";
  all = [
    hyperion
    simmons
    simmons-home
    lusus
    lusus-home
  ];
in {
  "password.age".publicKeys = all;
  "restic_password.age".publicKeys = all;
  "tailscale.age".publicKeys = all;
  "grafana.age".publicKeys = all;
  "gh-token.age".publicKeys = all;
  "miniflux.age".publicKeys = all;
  "factorio.age".publicKeys = all;
  "mullvad.conf.age".publicKeys = all;
  "woodpecker.age".publicKeys = all;
}
