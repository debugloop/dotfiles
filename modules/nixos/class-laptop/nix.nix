{...}: {
  nix.settings.extra-substituters = [
    "ssh://nix-ssh@hyperion?trusted=true&ssh-key=/etc/ssh/ssh_host_ed25519_key&priority=100&base64-ssh-public-host-key=c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUw1QXNTdm1oMC9qUHpsNGdEeW5ZdVBuSTR5RmtLOXNyYkF4UHNRZ0wvc0UK&compress=true"
  ];
}
