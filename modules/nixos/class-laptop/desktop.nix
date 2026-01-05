{
  pkgs,
  inputs,
  perSystem,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

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
    # noto-fonts
    # noto-fonts-monochrome-emoji
    # noto-fonts-lgc-plus
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
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet # required system-wide for icons
  ];

  services = {
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
  };

  security = {
    pam.services = {
      swaylock = { };
      login.enableGnomeKeyring = true;
    };
    rtkit.enable = true; # for pipewire
  };
}
