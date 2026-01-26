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
