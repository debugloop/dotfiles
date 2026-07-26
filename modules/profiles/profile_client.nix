_: {
  flake.modules.nixos.profile_client = {
    config,
    inputs,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      applications
      audio
      bluetooth
      cloud_tools
      desktop
      display
      fonts
      ddc
      graphics
      power
      scanning
      udev
      microvm
      mullvad
      networkmanager
      niri
      substituters
      swaylock
      printing
      theme
      docker
      flatpak
      # zed
    ];

    backup.exclude = [
      "home/${config.mainUser}/scratch"
      "home/${config.mainUser}/downloads"
    ];

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.profile_client];
  };

  flake.modules.homeManager.profile_client = {
    inputs,
    pkgs,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      failure_notify
      ghostty
      kitty
      # helix
      mako
      osd
      swayidle
      ssh_notify
      cloud_tools
      waybar
      wl_kbptr
      wofi
    ];

    home.packages = with pkgs; [
      jupyter
      mermaid-cli
    ];
  };
}
