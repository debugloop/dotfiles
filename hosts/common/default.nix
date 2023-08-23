{ config, lib, pkgs, inputs, hostname, ... }:
{
  imports =
    [
      ./base.nix
      ./impermanence.nix
      ./software.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
    ];

  system = {
    stateVersion = "22.11";
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
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

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  hardware.bluetooth.enable = true;

  users = {
    mutableUsers = false;
    users.danieln = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "docker" "libvirtd" ];
      shell = pkgs.fish;
      passwordFile = config.age.secrets.password.path;
    };

    # NOTE: This is of course not smart, but should not matter as it is only
    # usable locally. Having this hash outside agenix keeps a backdoor for
    # myself open in case something goes wrong with agenix, impermanence, or
    # anything else.
    users.root.initialHashedPassword = "$y$j9T$1DGnFy3m6PTbQoYB5kICV1$7gzz.2guf2Lj1wy4uo.YR0r1TfhI6/OTvjSi7.Tcm56";
  };
}

