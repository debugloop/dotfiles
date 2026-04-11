{top, inputs, ...}: {
  imports = with top.modules.home; [
    common_base
    common_claude
    common_cloud
    common_colors
    common_development
    common_extra
    common_fish
    common_git
    common_helix
    common_nix
    common_nvim
    common_starship
    laptop_ai
    laptop_applications
    laptop_base
    laptop_clipman
    laptop_ghostty
    laptop_kanshi
    laptop_kitty
    laptop_mako
    laptop_niri
    laptop_osd
    laptop_swayidle
    laptop_swaylock
    laptop_waybar
    laptop_wl_kbptr
  ] ++ [inputs.agenix.homeManagerModules.default inputs.gridx.home-module];
}
