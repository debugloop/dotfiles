{ inputs, ... }:

{
  imports =
    [
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
    ];

  system = {
    stateVersion = "22.11";
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    extra-substituters = [ "https://viperml.cachix.org" ];
    extra-trusted-public-keys = [ "viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8=" ];
    trustedUsers = [ "root" "@wheel" ];
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  age = {
    identityPaths = [ "/nix/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      password.file = ../../secrets/password.age;
    };
  };

}
