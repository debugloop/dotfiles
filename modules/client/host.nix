_: {
  flake.nixosModules.client = {top, ...}: {
    imports = with top.nixosModules; [
      host
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
}
