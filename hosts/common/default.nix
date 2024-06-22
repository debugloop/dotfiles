{ config, inputs, lib, pkgs, hostname, ... }:
{
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      ./nix.nix
      ./software.nix
    ];

  networking = {
    hostName = hostname;
    nftables.enable = true;
  };

  time = {
    timeZone = "Europe/Berlin";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = { LC_TIME = "en_GB.UTF-8"; };
    supportedLocales = [ "en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" ];
  };

  users = {
    mutableUsers = false;
    users.danieln = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "docker" "libvirtd" "dialout" ];
      shell = pkgs.fish;
      passwordFile = config.age.secrets.password.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJvfqr6PpG4BHmUHcj7LzfYhPjoxGeLGxNGF6FAXauX danieln@clarke"
      ];
    };

    users.root = {
      # NOTE: This is of course not smart, but should not matter as it is only
      # usable locally. Having this hash outside agenix keeps a backdoor for
      # myself open in case something goes wrong with agenix, impermanence, or
      # anything else.
      initialHashedPassword = "$y$j9T$1DGnFy3m6PTbQoYB5kICV1$7gzz.2guf2Lj1wy4uo.YR0r1TfhI6/OTvjSi7.Tcm56";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJvfqr6PpG4BHmUHcj7LzfYhPjoxGeLGxNGF6FAXauX danieln@clarke"
      ];
    };
  };

  virtualisation.vmVariant = {
    # better performance and no qcow, it's not persisted anyhow
    virtualisation = {
      memorySize =  2048;
      cores = 2;
      diskImage = null;
      # launch in a useable and graphical window
      qemu.options = [
        "-vga virtio"
        "-display gtk,zoom-to-fit=false"
      ];
    };
    environment.persistence = lib.mkForce { };
    # empty password for myself
    age = lib.mkForce { };
    users.users.danieln.passwordFile = lib.mkForce null;
    users.users.danieln.initialHashedPassword = "";
  };
}

