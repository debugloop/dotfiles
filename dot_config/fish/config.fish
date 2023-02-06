# locale
set -x LANG "en_US.UTF-8"
set -x LC_TIME "en_GB.UTF-8"

# defaults
set -x EDITOR "nvim"
set -x VISUAL "nvim"
set -x PAGER "less -R --use-color -Dd+r -Du+b"

# tools
set -x HIGHLIGHT_STYLE "base16/grayscale-dark"
set -x BAT_THEME "ansi"

# start sway
if status is-login
    [ (tty) = /dev/tty1 ] && exec sway &>~/.Wsession.errors
end

# fish styles
set -g fish_greeting ""
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_visual block
set -g fish_prompt_pwd_dir_length 0
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_color_branch magenta
set -g __fish_git_prompt_color_dirtystate blue
set -g __fish_git_prompt_color_untrackedfiles brblack
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_cleanstate green

# keyboard
function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
    fzf_key_bindings
    bind -M insert \cz 'fg 2>/dev/null; commandline -f repaint'
end

# user stuff
function r --description 'Launch ranger if this terminal does not have one yet'
    set NUM (pstree -s %self | grep -o ranger | wc -l)
    if test $NUM -eq 0
        ranger && history --merge
    else
        exit
    end
end

abbr --add nix-shell "nix-shell --command fish"
alias hl=hledger
alias dell='sudo ddcutil -b 12 setvcp 10'
alias cvim=/usr/bin/vim
alias vim=nvim
alias vimdiff='nvim -d'
alias docker_ip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias ip='ip -c'
alias dmesg='dmesg -T'
alias ls='exa'
alias ag='rg'
alias cat='bat'
alias sloc='tokei'
alias cloc='tokei'
alias past="curl -F 'f:1=<-' ix.io | wl-copy"
alias s="kitty +kitten ssh"
