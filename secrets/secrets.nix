let
  simmons = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6PfN5CQE9VRocpilzDhhfaHfQwwC0mZkx4ndYTsS75";
  hyperion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5AsSvmh0/jPzl4gDynYuPnI4yFkK9srbAxPsQgL/sE";
  lusus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIII2XSMk/4DoyRzSts/YeU8iN+eNDeRiNmfrHCmutcpQ";
  all = [simmons hyperion lusus];
in {
  "password.age".publicKeys = all;
  "restic_rclone_config.age".publicKeys = all;
  "restic_password.age".publicKeys = all;
  "tailscale.age".publicKeys = all;
  "grafana.age".publicKeys = all;
  "miniflux.age".publicKeys = all;
}
