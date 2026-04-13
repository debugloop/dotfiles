_: {
  flake.homeModules.danieln_full = {top, ...}: {
    imports = with top.homeModules; [
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
