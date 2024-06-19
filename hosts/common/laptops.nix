{ pkgs, ... }:

{
  imports =
    [
      ./impermanence.nix
    ];

  networking = {
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      6443
    ];
  };
  hardware = {
    bluetooth.enable = true;
    opengl.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  security = {
    pam.services.swaylock = { };
    rtkit.enable = true;
    sudo.extraRules = [
      {
        # needed for setting external monitor brightness
        groups = [ "wheel" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/ddcutil";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/k3s";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
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
    jetbrains-mono
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" "Noto" ]; })
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
      enable = true;
      role = "server";
      extraFlags = toString [ ];
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

  programs = {
    light.enable = true;
    nm-applet.enable = true;
    sway = {
      enable = true;
      extraPackages = [ ];
    };
  };
}
