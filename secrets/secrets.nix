let
  simmons = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6PfN5CQE9VRocpilzDhhfaHfQwwC0mZkx4ndYTsS75";
  clarke = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbV3a87YcN9cxWyUeY6nAxpLGBxFJuAyC7Mh2iM6BJY";
  hyperion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5AsSvmh0/jPzl4gDynYuPnI4yFkK9srbAxPsQgL/sE";
  all = [ simmons clarke hyperion ];
in
{
  "password.age".publicKeys = all;
  "restic_rclone_config.age".publicKeys = all;
  "restic_password.age".publicKeys = all;
}
