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
        "ssh://nix-ssh@hyperion?trusted=true&ssh-key=/etc/ssh/ssh_host_ed25519_key&priority=100"
      ];
      trusted-users = ["@wheel"];
    };
  };
  # to be able to use above ssh entry as a substituter via ssh
  programs.ssh.knownHosts.hyperion = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5AsSvmh0/jPzl4gDynYuPnI4yFkK9srbAxPsQgL/sE";
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
