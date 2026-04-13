_: {
  flake.modules.nixos.client = {inputs, ...}: {
    imports = with inputs.self.modules.nixos; [
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

    home-manager.users.danieln.imports = [inputs.self.modules.homeManager.danieln_full];
  };
}
