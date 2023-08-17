{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        bufferline = "multiple";
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
      keys.normal = {
        space.space = "file_picker";
        tab = "goto_next_buffer";
        "S-tab" = "goto_previous_buffer";
      };
    };
  };
}
