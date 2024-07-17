{pkgs, ...}: {
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
        indent-guides = {
          render = true;
          character = "·";
        };
        statusline = {
          left = ["mode" "spacer" "version-control" "workspace-diagnostics" "file-name" "diagnostics"];
          center = [];
          right = ["file-type" "position-percentage" "total-line-numbers"];
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
      };
      keys.normal = {
        tab = "goto_next_buffer";
        "S-tab" = "goto_previous_buffer";
      };
    };
  };
}
