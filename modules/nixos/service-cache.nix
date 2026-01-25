{...}: {
  nix.sshServe = {
    enable = true;
    keys = [
      # TODO: These also live in secrets. Centralize somewhere.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6PfN5CQE9VRocpilzDhhfaHfQwwC0mZkx4ndYTsS75" # simmons
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIII2XSMk/4DoyRzSts/YeU8iN+eNDeRiNmfrHCmutcpQ" # lusus
    ];
  };
}
