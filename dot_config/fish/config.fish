#####################################################################
# basic settings {{{
#####################################################################
set -x LANG en_US.UTF-8
set -x LC_TIME en_GB.UTF-8
set -x EDITOR nvim
set -x GTK_THEME "Arc-Darker"
set -x HIGHLIGHT_STYLE "base16/grayscale-dark"
set -x BAT_THEME "ansi"

set fish_greeting ""

function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
    fzf_key_bindings
    bind -M insert \cx "fg &> /dev/null"
end

set -x NVIM_TUI_ENABLE_TRUE_COLOR 1
set -x MANWIDTH 100
set -x LESS_TERMCAP_mb (printf "\033[01;31m")
set -x LESS_TERMCAP_md (printf "\033[01;31m")
set -x LESS_TERMCAP_me (printf "\033[0m")
set -x LESS_TERMCAP_se (printf "\033[0m")
set -x LESS_TERMCAP_so (printf "\033[01;44;33m")
set -x LESS_TERMCAP_ue (printf "\033[0m")
set -x LESS_TERMCAP_us (printf "\033[01;32m")

if test -n "$DISPLAY"
    for env_var in (gnome-keyring-daemon --start);
        set -x (echo $env_var | string split "=")
    end
end

set fish_color_search_match --background=magenta

# }}}

#####################################################################
# prompt stuff {{{
#####################################################################
set -g fish_prompt_pwd_dir_length 0

set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_color_branch magenta
set -g __fish_git_prompt_showupstream "informative"
set -g __fish_git_prompt_color_dirtystate blue
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_cleanstate green
# }}}

#####################################################################
# custom commands {{{
#####################################################################
function unclean_repos
    for path in (find -name ".git" -type d | grep -v "/.cache/")
        cd $path/..
        git status | grep clean > /dev/null
        if test $status -ne 0
            echo $path/..
        end
        cd -
    end
end

function r --description 'Launch ranger if this terminal does not have one yet'
    set NUM (pstree -s %self | grep -o ranger | wc -l)
    if test $NUM -eq 0
        ranger && history --merge
    else
        exit
    end
end


set -x LEDGER_FILE /home/danieln/finance/hledger.journal
alias hl=hledger

alias dell='sudo ddcutil -b 12 setvcp 10'
alias cvim=/usr/bin/vim
alias vim=nvim
alias vimdiff='nvim -d'
alias irc='mosh -p 61293 irc -- tmux a -t 0 -d'
alias docker_ip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias merge_pdf="gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=merged.pdf"
alias ip='ip -c'
alias dmesg='dmesg -T'
alias ls='exa'
alias ag='rg'
alias cat='bat'
alias sloc='tokei'
alias cloc='tokei'
alias past="curl -F 'f:1=<-' ix.io | wl-copy"
# }}}

#####################################################################
# external addons {{{
#####################################################################
direnv hook fish | source
# }}}
