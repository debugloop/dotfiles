# locales
set -x LANG "en_US.UTF-8"
set -x LC_TIME "en_GB.UTF-8"

# unix defaults
set -x EDITOR "nvim"
set -x VISUAL "nvim"
set -x PAGER "less -R --use-color -Dd+r -Du+b"

# tool configuration
set -x HIGHLIGHT_STYLE "base16/grayscale-dark"
set -x BAT_THEME "ansi"

# kanagawa colors
set -l foreground DCD7BA
set -l selection 2D4F67
set -l comment 727169
set -l red C34043
set -l orange FF9E64
set -l yellow C0A36E
set -l green 76946A
set -l purple 957FB8
set -l cyan 7AA89F
set -l pink D27E99

# fish styles
set -g fish_greeting ""
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_visual block
set -g fish_prompt_pwd_dir_length 0

# keyboard
function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
    fzf_key_bindings
    bind -M insert \cz 'fg 2>/dev/null; commandline -f repaint'
end

# functions and aliases
function r --description 'Launch ranger if this terminal does not have one yet'
    set NUM (pstree -s %self | grep -o ranger | wc -l)
    if test $NUM -eq 0
        ranger && history --merge
    else
        exit
    end
end

alias ag='rg'
alias cat='bat'
alias cloc='tokei'
alias cvim=/usr/bin/vim
alias dell='sudo ddcutil -b 12 setvcp 10'
alias dmesg='dmesg -T'
alias docker-ip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias hl=hledger
alias ip='ip -c'
alias ls='exa'
alias nix-shell="nix-shell --command fish"
alias past="curl -F 'f:1=<-' ix.io | wl-copy"
alias s="kitty +kitten ssh"
alias sloc='tokei'
alias vimdiff='nvim -d'
alias vim=nvim

# external tools
direnv hook fish | source
starship init fish | source

# start sway on tty1
if status is-login
    [ (tty) = /dev/tty1 ] && exec sway &>~/.Wsession.errors
end

# connect to gnome-keyring in graphical terminals
if test -n "$DISPLAY"
    for env_var in (gnome-keyring-daemon --start 2>/dev/null);
        set -x (echo $env_var | string split "=")
    end
end
