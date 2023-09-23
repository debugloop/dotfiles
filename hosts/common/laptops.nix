{ pkgs, ... }:

{
  imports =
    [
      ./impermanence.nix
    ];

  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  security.sudo.extraRules = [
    {
      # needed for setting external monitor brightness
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/ddcutil";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    ddcutil # see above sudo rule
    networkmanagerapplet # required system-wide for icons
    pinentry-emacs.gnome3 # required for gnupg agent
  ];

  fonts.packages = with pkgs; [
    fira
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
    # fallback to render all chars
    noto-fonts
    noto-fonts-emoji
    noto-fonts-extra
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  services = {
    blueman.enable = true;
    gnome.gnome-keyring = {
      enable = true;
    };
    pcscd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    printing.enable = true;
    tlp.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    light.enable = true;
    nm-applet.enable = true;
    hyprland = {
      enable = true;
    };
  };
}
