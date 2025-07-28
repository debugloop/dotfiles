{pkgs, ...}: {
  programs.helix = {
    enable = true;
    themes = {
      mykanagawa = {
        inherits = "kanagawa";
        "ui.bufferline.active" = {
          bg = "blue";
          fg = "black";
        };
      };
    };
    settings = {
      theme = "mykanagawa";
      editor = {
        bufferline = "multiple";
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        soft-wrap = {
          enable = true;
        };
        inline-diagnostics = {
          cursor-line = "hint";
        };
        lsp = {
          goto-reference-include-declaration = false;
        };
        cursorline = true;
        color-modes = true;
        indent-guides = {
          render = true;
          character = "·";
          skip-levels = 1;
        };
        statusline = {
          left = ["mode" "spacer" "version-control" "workspace-diagnostics"];
          center = ["file-name" "spinner"];
          right = ["diagnostics" "file-type" "position-percentage" "total-line-numbers"];
        };
      };
      keys = {
        normal = {
          tab = "goto_next_buffer";
          S-tab = "goto_previous_buffer";
          backspace = "jump_backward";
          S-backspace = "jump_forward";
          H = "goto_first_nonwhitespace";
          L = "goto_line_end";
          "-" = [":open %sh{lf --print-selection %{buffer_name}}" ":redraw"];
          w = "move_next_sub_word_start";
          e = "move_next_sub_word_end";
          b = "move_prev_sub_word_start";
          C-h = "jump_view_left";
          C-j = "jump_view_down";
          C-k = "jump_view_up";
          C-l = "jump_view_right";
          K = "hover";
          esc = ["collapse_selection" "keep_primary_selection"];
          A-k = "keep_selections";
          space = {
            g = {
              b = ":echo %sh{git log --pretty=format:'%%an, %%ad: %%s' --date=relative --no-patch -1 -L %{cursor_line},+1:%{buffer_name}}";
              g = "changed_file_picker";
            };
            t = ":! gotest ./$(dirname %{buffer_name})";
            T = '':! echo "fd -ego . $(dirname %{buffer_name}) | entr -cr gotest ./$(dirname %{buffer_name})" | wl-copy'';
            tab = ":buffer-close";
            k = ":debug-eval %{selection}";
            G = {
              t = ":debug-start test %sh{dirname %{buffer_name}}";
              r = ":debug-remote remote 127.0.0.1:2345";
            };
          };
        };
        select = {
          w = "extend_next_sub_word_start";
          e = "extend_next_sub_word_end";
          b = "extend_prev_sub_word_start";
          A-k = "keep_selections";
          esc = ["collapse_selection" "keep_primary_selection" "normal_mode"];
        };
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "alejandra";
        }
        {
          name = "go";
          auto-format = true;
          formatter = {
            command = "bash";
            args = ["-c" "${pkgs.gofumpt}/bin/gofumpt | ${pkgs.goimports-reviser}/bin/goimports-reviser -rm-unused -"];
          };
          language-servers = ["gopls" "golangci-lint-langserver"];
          indent = {
            tab-width = 8;
            unit = "\t";
          };
          debugger = {
            name = "go";
            transport = "tcp";
            command = "${pkgs.delve}/bin/dlv";
            args = ["dap"];
            port-arg = "-l 127.0.0.1:{}";
            templates = [
              {
                name = "test";
                request = "launch";
                completion = [
                  {
                    name = "test";
                    completion = "directory";
                    default = "./...";
                  }
                ];
                args = {
                  mode = "test";
                  program = "{0}";
                  buildFlags = "-tags=unit,integration,e2e";
                };
              }
              {
                name = "remote";
                request = "attach";
                args = {
                  mode = "remote";
                };
              }
            ];
          };
        }
      ];
      language-server.golangci-lint-langserver = with pkgs; {
        command = "${golangci-lint-langserver}/bin/golangci-lint-langserver";
        config = {
          command = [
            "${golangci-lint}/bin/golangci-lint"
            "run"
            "--output.json.path=stdout"
            "--show-stats=false"
            "--issues-exit-code=1"
          ];
        };
      };
      language-server.gopls = with pkgs; {
        command = "${gopls}/bin/gopls";
        config = {
          buildFlags = ["-tags=unit,integration,e2e"];
          directoryFilters = ["-.git"];
          gofumpt = true;
          codelenses = {
            test = true;
            vulncheck = true;
          };
          semanticTokens = true;
          staticcheck = true;
          vulncheck = "Imports";
          hints = {
            assignVariableTypes = true;
            compositeLiteralFields = true;
            compositeLiteralTypes = true;
            constantValues = true;
            functionTypeParameters = true;
            parameterNames = true;
            rangeVariableTypes = true;
          };
          completeUnimported = true;
          deepCompletion = true;
        };
      };
    };
  };
}
