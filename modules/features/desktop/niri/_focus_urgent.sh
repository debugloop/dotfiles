window_id="$(niri msg --json windows | jq -r '
  map(select(.is_urgent and (.is_focused | not)))
  | sort_by(.id)
  | .[0].id // empty
')"

if [[ -n "$window_id" ]]; then
  exec niri msg action focus-window --id "$window_id"
fi
