#!/bin/fish
set pid (pgrep -f "waybar -b net")

if not test -z "$pid"
    kill $pid
else
    waybar -b net -c ~/.config/waybar/net_config &
end
