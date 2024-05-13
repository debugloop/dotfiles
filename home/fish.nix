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
      set fish_cursor_default block
      set fish_cursor_insert line
      set fish_cursor_visual block

      # connect to gnome-keyring in graphical terminals
      if test -n "$DISPLAY"
        for env_var in (gnome-keyring-daemon --start 2>/dev/null);
          set -x (echo $env_var | string split "=")
        end
      end

      set -x SHELL_NAME "$(random choice affectionate agitated amazing angry awesome beautiful blissful bold boring brave busy charming clever competent condescending confident cool cranky crazy dazzling determined distracted dreamy eager elastic elated elegant eloquent epic exciting fervent festive flaming focused friendly frosty funny gallant gifted goofy gracious great happy hardcore hopeful hungry infallible inspiring jolly jovial kind laughing loving magical modest musing mystifying naughty nervous nice nifty nostalgic objective optimistic peaceful pedantic pensive practical priceless quirky quizzical recursing relaxed reverent romantic sad serene sharp silly sleepy stoic strange suspicious sweet tender thirsty trusting unruffled upbeat vibrant vigilant wonderful youthful)_$(random choice adleman bernerslee cerf chomsky conway diffie dijkstra engelbart gauss gödel hamming hellman kay knuth lamport leibniz lovelace neumann pascal perlman pike postel ritchie rivest shamir strousrup thompson torvalds turing wirth zuse adams asimov bradbury clarke dickens doyle heinlein hemingway herbert huxley jordan king leguin lem lewis lovecraft martin orwell poe pratchett reynolds robinson rothfuss sanderson simmons stoker tolkien twain verne vonnegut wells)"
    '';
    loginShellInit = ''
      # start sway on tty1
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
          set -q argv[1]; or set argv shell
          echo "[$SHELL_NAME] $argv - in $(fish_prompt_pwd_dir_length=0 prompt_pwd)";
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
      tcurl = "curl -s -o /dev/null -w 'time_namelookup: %{time_namelookup}\ntime_connect: %{time_connect}\ntime_appconnect: %{time_appconnect}\ntime_pretransfer: %{time_pretransfer}\ntime_redirect: %{time_redirect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}\n'";
      dmesg = "dmesg -T";
      docker-ip = "docker inspect --format '{{ .NetworkSettings.IPAddress }}'";
      ip = "ip -c";
      s = "kitty +kitten ssh";
      c = "cd (git rev-parse --show-toplevel)";
      sloc = "tokei";
      v = "vim (git f)";
      vim = "nvim";
      vimdiff = "nvim -d";
    };
  };
}
