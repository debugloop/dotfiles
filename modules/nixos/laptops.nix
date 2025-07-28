{
  pkgs,
  lib,
  inputs,
  perSystem,
  ...
}: {
  imports = [
    inputs.niri.nixosModules.niri
  ];

  networking = {
    networkmanager = {
      enable = true;
      plugins = lib.mkForce [];
      logLevel = "INFO";
      wifi = {
        scanRandMacAddress = false;
        # backend = "iwd";
      };
    };
    firewall.allowedTCPPorts = [
      6443
    ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
    graphics.enable = true;
    sane.enable = true;
  };

  virtualisation = {
    docker = {
      # enable = true;
      # daemon.settings = {
      #   bip = "10.200.0.1/24";
      #   default-address-pools = [
      #     {
      #       base = "10.201.0.0/16";
      #       size = 24;
      #     }
      #     {
      #       base = "10.202.0.0/16";
      #       size = 24;
      #     }
      #   ];
      # };
      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          bip = "10.200.0.1/24";
          default-address-pools = [
            {
              base = "10.201.0.0/16";
              size = 24;
            }
            {
              base = "10.202.0.0/16";
              size = 24;
            }
          ];
        };
      };
    };
  };

  security = {
    pam.services.swaylock = {};
    rtkit.enable = true;
    sudo = {
      extraConfig = ''
        Defaults passprompt="[sudo] password for %p: "
      '';
      extraRules = [
        {
          groups = ["wheel"];
          commands = [
            {
              # needed for setting external monitor brightness
              command = "/run/current-system/sw/bin/ddcutil";
              options = ["NOPASSWD"];
            }
            {
              command = "/run/current-system/sw/bin/k3s";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    # brightness control
    light # better commands
    ddcutil # external displays
    networkmanagerapplet # required system-wide for icons
  ];

  fonts.packages = with pkgs; [
    fira
    fira-code
    fira-code-symbols
    fira-go
    fira-math
    iosevka
    # nerd-fonts.fira-code
    # nerd-fonts.fira-mono
    # nerd-fonts.noto
    # nerd-fonts.iosevka
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-extra
    noto-fonts-monochrome-emoji
    noto-fonts-lgc-plus
    roboto
    roboto-mono
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config = {
      common = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.Notification" = "gtk";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
    };
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  services = {
    avahi.enable = true;
    blueman.enable = true;
    gnome.gnome-keyring = {
      enable = true;
    };
    gvfs.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      wireplumber.enable = true;
    };
    printing.enable = true;
    tlp.enable = true;
    udev = {
      packages = [
        pkgs.light
        pkgs.libmtp.out
      ];
      extraRules = ''
        # generic stm32 keyboard flashing
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666"

        # fazua ebike integration
        SUBSYSTEM!="usb|usb_device", GOTO="ebike_rules_end"
        ACTION!="add", GOTO="ebike_rules_end"
        # 10c4:1000 for E-Bike Bootloader mode
        ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="1000", MODE="0666", SYMLINK+="ebike-bootloader-%n"
        # 10c4:100X for E-Bikes regular operation
        ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="1001", MODE="0666", SYMLINK+="ebike-brain-%n"
        # 10c4:100X for Lola device
        ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="1002", MODE="0666", SYMLINK+="lola-%n"
        LABEL="ebike_rules_end"
      '';
    };
  };

  programs = {
    niri = {
      enable = true;
      package = perSystem.niri.niri-unstable;
    };
    thunar = {
      enable = false;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
}
