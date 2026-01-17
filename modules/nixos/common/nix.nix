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
      substituters = [
        "https://cache.garnix.io"
        "https://viperml.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = ["root" "@wheel"];
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
