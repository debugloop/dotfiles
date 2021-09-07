#!/bin/bash

pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes

case $? in
0)
    echo "{\"text\":\"\",\"icon\":\"microphone_muted\",\"state\":\"Good\"}";;
*)
    echo "{\"text\":\"\",\"icon\":\"microphone_full\",\"state\":\"Critical\"}";;
esac

