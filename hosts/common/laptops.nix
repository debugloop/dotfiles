{pkgs, ...}: {
  networking = {
    networkmanager = {
      enable = true;
      # logLevel = "DEBUG";
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
    bluetooth.enable = true;
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
    ddcutil # see above sudo rule
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
  };

  services = {
    blueman.enable = true;
    gnome.gnome-keyring = {
      enable = true;
    };
    k3s = {
      enable = false;
      role = "server";
      extraFlags = toString [];
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    printing.enable = true;
    tlp.enable = true;
    udev.extraRules = ''
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

  systemd.services.shutdown-k3s = {
    enable = true;
    description = "ensure k3s shuts down correctly";
    unitConfig = {
      DefaultDependencies = false;
      Before = [
        "shutdown.target"
        "umount.target"
      ];
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.k3s}/bin/k3s-killall.sh";
    };
    wantedBy = ["shutdown.target"];
  };

  programs = {
    light.enable = true;
    nm-applet.enable = true;
    sway = {
      enable = true;
      extraPackages = [];
    };
  };
}
