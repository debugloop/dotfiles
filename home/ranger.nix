{ ... }:

{
  imports = [
    ./modules/ranger.nix
  ];
  programs.ranger = {
    enable = true;
    enableFishIntegration = true;
    extraConfig = ''
      map s shell $SHELL
      map R bulkrename
      map r rename

      map m copy mode=toggle
      map M uncut
      map e shell nvim %c

      set vcs_aware true
      set draw_borders separators
      set nested_ranger_warning error
      set preview_images true
      set preview_images_method kitty
    '';
  };
}
