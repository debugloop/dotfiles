let
  danieln = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXLvABfBx2ThhJ/nUYaLFu2QyLYomOn4BrKUnbwGeWk";
  users = [ danieln ];

  simmons = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6PfN5CQE9VRocpilzDhhfaHfQwwC0mZkx4ndYTsS75";
  clarke = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbV3a87YcN9cxWyUeY6nAxpLGBxFJuAyC7Mh2iM6BJY";
  systems = [ simmons clarke ];
in
{
  "password.age".publicKeys = users ++ systems;
  "restic_rclone_config.age".publicKeys = users ++ systems;
  "restic_password.age".publicKeys = users ++ systems;
}
