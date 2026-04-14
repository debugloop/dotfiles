_: {
  flake.modules.homeManager.danieln_full = {inputs, ...}: {
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
