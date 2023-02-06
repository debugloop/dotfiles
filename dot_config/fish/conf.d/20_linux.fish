set -x GTK_THEME "Arc-Darker"
set -x LEDGER_FILE /home/danieln/finance/hledger.journal

if test -n "$DISPLAY"
    for env_var in (gnome-keyring-daemon --start 2>/dev/null);
        set -x (echo $env_var | string split "=")
    end
end

direnv hook fish | source
starship init fish | source
