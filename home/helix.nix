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
    languages = {
      language = [
        {
          name = "go";
          config = {
          "build.buildFlags" = ["-tags=unit"];
          };
        }
      ];
      debugger = [
      {
        name = "go";
        transport = "tcp";
        command = "dlv";
        args = [
          "dap"
        ];
        port-arg = "--build-flags='-tags=unit' -l 127.0.0.1:{}";
      }
      ];
    };
  };
}
