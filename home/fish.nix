{ pkgs, config, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_color_normal ${config.colors.foreground}
      set -g fish_color_command ${config.colors.cyan}
      set -g fish_color_keyword ${config.colors.bright-purple}
      set -g fish_color_quote ${config.colors.yellow}
      set -g fish_color_redirection ${config.colors.foreground}
      set -g fish_color_end ${config.colors.bright-red}
      set -g fish_color_error ${config.colors.red}
      set -g fish_color_param ${config.colors.purple}
      set -g fish_color_comment ${config.colors.bright-black}
      set -g fish_color_selection --background=${config.colors.blue}
      set -g fish_color_search_match --background=${config.colors.blue}
      set -g fish_color_operator ${config.colors.green}
      set -g fish_color_escape ${config.colors.bright-purple}
      set -g fish_color_autosuggestion ${config.colors.bright-black}
      set -g fish_pager_color_progress ${config.colors.bright-black}
      set -g fish_pager_color_prefix ${config.colors.cyan}
      set -g fish_pager_color_completion ${config.colors.foreground}
      set -g fish_pager_color_description ${config.colors.bright-black}

      set fish_greeting ""

      set fish_vi_force_cursor 1
      set fish_cursor_default block
      set fish_cursor_insert line
      set fish_cursor_visual block

      # connect to gnome-keyring in graphical terminals
      if test -n "$DISPLAY"
        for env_var in (gnome-keyring-daemon --start 2>/dev/null);
          set -x (echo $env_var | string split "=")
        end
      end
    '';
    loginShellInit = ''
      # start wm on tty1
      if test (tty) = /dev/tty1
        sway
      end
    '';
    shellAbbrs = {
      g = "git";
      d = "dlv --headless -l 'localhost:2345'";
    };
    functions = {
      fish_title = {
        body = ''
          set -q argv[1]; or set argv fish
          echo (fish_prompt_pwd_dir_length=0 prompt_pwd): $argv;
        '';
      };
      persistent = {
        body = ''
          	  test (findmnt -JT (pwd) | jq -r '.filesystems[0].fstype') = "xfs"
        '';
      };
      asname = {
        body = ''
          dig +short AS$argv.asn.cymru.com txt
        '';
      };
      asn = {
        body = ''
          switch $argv
            case "*.*" 
              set six ""
            case '*:*'
              set six "6"
          end
          set out (host $argv | sed -r "s/(Host )?(.*)\.i.*/\2.origin$six.asn.cymru.com/" | xargs -l dig +short txt)
          set asn (echo $out | read | sed -r 's/"([0-9]+) .*/\1/')
          for line in $out
            echo $line
          end
          asname $asn
        '';
      };
      fish_user_key_bindings = {
        body = ''
          fish_hybrid_key_bindings
          bind -M insert \cz 'fg 2>/dev/null;
          commandline -f repaint'
        '';
      };
    };
    shellAliases = {
      ag = "rg";
      cat = "bat";
      cloc = "tokei";
      ext_brightness = "sudo ddcutil -d 1 setvcp 10";
      kloc = "kubectl --context=local";
      tcurl = "curl -s -o /dev/null -w 'time_namelookup: %{time_namelookup}\ntime_connect: %{time_connect}\ntime_appconnect: %{time_appconnect}\ntime_pretransfer: %{time_pretransfer}\ntime_redirect: %{time_redirect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}\n'";
      dmesg = "dmesg -T";
      docker-ip = "docker inspect --format '{{ .NetworkSettings.IPAddress }}'";
      ip = "ip -c";
      c = "cd (git rev-parse --show-toplevel)";
      sloc = "tokei";
      s = "kitten ssh";
      v = "vim (git f)";
      vim = "nvim";
      vimdiff = "nvim -d";
    };
  };
}
