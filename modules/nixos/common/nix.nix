{inputs, ...}: {
  imports = [
    inputs.agenix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  system = {
    stateVersion = "22.11";
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      extra-substituters = [
        "ssh://nix-ssh@hyperion?trusted=true&ssh-key=/etc/ssh/ssh_host_ed25519_key&priority=100&base64-ssh-public-host-key=c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUw1QXNTdm1oMC9qUHpsNGdEeW5ZdVBuSTR5RmtLOXNyYkF4UHNRZ0wvc0UK&compress=true"
      ];
      trusted-users = ["@wheel"];
    };
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config = {
      allowUnfree = true;
      warnUndeclaredOptions = true;
    };
    overlays = [
      # inputs.neovim-nightly-overlay.overlays.default
    ];
  };

  age = {
    identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      password.file = ../../../secrets/password.age;
    };
  };
}
