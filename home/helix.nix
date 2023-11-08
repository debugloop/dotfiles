{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "kanagawa";
      editor = {
        bufferline = "multiple";
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        cursorline = true;
        color-modes = true;
      };
      keys.normal = {
        tab = "goto_next_buffer";
        "S-tab" = "goto_previous_buffer";
      };
    };
  };
}
