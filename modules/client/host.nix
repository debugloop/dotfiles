_: {
  flake.modules.nixos.client = {
    config,
    inputs,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      host
      applications
      audio
      bluetooth
      desktop
      fonts
      hardware
      microvm
      mullvad
      networkmanager
      niri
      substituters
      printing
      swaylock
      docker
      flatpak
    ];

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.client];
  };

  flake.modules.homeManager.client = {inputs, ...}: {
    imports = with inputs.self.modules.homeManager; [
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
