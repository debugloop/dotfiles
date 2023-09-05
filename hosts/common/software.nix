{ pkgs, inputs, ... }:

{
  fonts.packages = with pkgs; [
    fira
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
    # fallback to render all chars
    noto-fonts
    noto-fonts-emoji
    noto-fonts-extra
  ];

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      EDITOR = "nvim";
      VISUAL = "nvim";
      GTK_THEME = "Arc-Darker";
      MOZ_ENABLE_WAYLAND = "1";
    };
    systemPackages = with pkgs; [
      # root stuff
      coreutils
      mkpasswd
      nettools
      pciutils
      procps
      psmisc
      usbutils

      # nix
      inputs.agenix.packages.x86_64-linux.default
      nixos-generators

      # hardware support
      efibootmgr
      xfsprogs
      ddcutil

      networkmanagerapplet # required system-wide for icons
      pinentry-emacs.gnome3 # required for gnupg agent
    ];
  };

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    fish.enable = true;
    light.enable = true;
    nm-applet.enable = true;
    mtr.enable = true;
    traceroute.enable = true;
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    hyprland = {
      enable = true;
    };
    zmap.enable = true;
  };

  services = {
    blueman.enable = true;
    dbus = {
      enable = true;
      packages = [ pkgs.gcr ];
    };
    gnome.gnome-keyring = {
      enable = true;
    };
    openssh.enable = true;
    pcscd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    printing.enable = true;
    prometheus.exporters = {
      node = {
        enable = false;
        enabledCollectors = [ "systemd" ];
      };
    };
    tlp.enable = true;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];
    wlr = {
      enable = false;
      settings = {
        screencast = {
          max_fps = 30;
          exec_before = "${pkgs.mako}/bin/makoctl set-mode dnd";
          exec_after = "${pkgs.mako}/bin/makoctl set-mode default";
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        };
      };
    };
  };
}
