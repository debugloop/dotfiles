while true; do
  if outputs="$(awww query "$@" 2>/dev/null)" && [[ -n "$outputs" ]]; then
    exit 0
  fi
  sleep 0.1
done
