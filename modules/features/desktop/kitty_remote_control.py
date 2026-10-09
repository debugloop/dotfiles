def is_cmd_allowed(cmd, window, from_socket, extra_data):
    payload = cmd.get("payload") or {}
    return (
        window is not None
        and not from_socket
        and cmd.get("cmd") == "action"
        and payload.get("action")
        in {
            "toggle_window_title_bars",
            "kitten kitty_title_bar.py show",
            "kitten kitty_title_bar.py hide",
            "kitten kitty_title_bar.py toggle",
            "kitten kitty_agent_window.py promote",
            "kitten kitty_agent_window.py restore",
        }
        and payload.get("self") is True
        and not payload.get("match_window")
    )
