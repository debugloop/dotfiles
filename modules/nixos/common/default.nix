{
  config,
  inputs,
  lib,
  pkgs,
  hostName,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./impermanence.nix
    ./nix.nix
    ./software.nix
    ./tailscale.nix
  ];

  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
    };
  };

  networking = {
    hostName = hostName;
    nftables.enable = true;
  };

  services = {
    resolved = {
      enable = true;
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
  };

  time = {
    timeZone = "Europe/Berlin";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {LC_TIME = "en_GB.UTF-8";};
    supportedLocales = ["en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8"];
  };

  users = {
    mutableUsers = false;
    users.danieln = {
      isNormalUser = true;
      extraGroups = ["wheel" "video" "docker" "libvirtd" "dialout" "scanner" "lp"];
      shell = pkgs.fish;
      hashedPasswordFile = config.age.secrets.password.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJvfqr6PpG4BHmUHcj7LzfYhPjoxGeLGxNGF6FAXauX danieln@lusus"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXLvABfBx2ThhJ/nUYaLFu2QyLYomOn4BrKUnbwGeWk danieln@simmons"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGO/7gSRKMzTR1bSjpirDN/AIG4Mw55GyiLck9ppvzj2 JuiceSSH"
      ];
    };

    users.root = {
      # NOTE: This is of course not smart, but should not matter as it is only
      # usable locally. Having this hash outside agenix keeps a backdoor for
      # myself open in case something goes wrong with agenix, impermanence, or
      # anything else.
      initialHashedPassword = "$y$j9T$1DGnFy3m6PTbQoYB5kICV1$7gzz.2guf2Lj1wy4uo.YR0r1TfhI6/OTvjSi7.Tcm56";
    };
  };

  virtualisation.vmVariant = {
    # better performance and no qcow, it's not persisted anyhow
    virtualisation = {
      memorySize = 2048;
      cores = 2;
      diskImage = null;
      qemu.options = [];
    };
    environment.persistence = lib.mkForce {};
    # empty password for myself
    age = lib.mkForce {};
    users.users.danieln.hashedPasswordFile = lib.mkForce null;
    users.users.danieln.initialHashedPassword = "";
  };

  security = {
    sudo = {
      extraConfig = ''
        Defaults passprompt="[sudo] password for %p: "
      '';
    };
  };
}
