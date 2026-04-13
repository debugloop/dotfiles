_: {
  flake.nixosModules.client = {top, ...}: {
    imports = with top.nixosModules; [
      home_manager
      network
      openssh
      locale
      users
      vm
      backup_persisted
      hetzner
      impermanence
      nix
      software
      tailscale
      applications
      audio
      bluetooth
      desktop
      fonts
      hardware
      microvm
      networkmanager
      niri
      substituters
      printing
      swaylock
      docker
      flatpak
    ];
  };

  flake.homeModules.client = {top, ...}: {
    imports = with top.homeModules; [
      ai
      applications
      clipman
      ghostty
      kanshi
      kitty
      mako
      osd
      swayidle
      waybar
      wl_kbptr
    ];
  };
}
