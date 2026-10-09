from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    if len(args) != 2 or args[1] not in {"promote", "restore"}:
        raise ValueError("Usage: kitten kitty_agent_window.py promote|restore")

    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    source_tab = window.tabref()
    if source_tab is None:
        return
    source_manager = source_tab.tab_manager_ref()
    if source_manager is None:
        return

    origin = getattr(window, "_agent_window_origin", None)
    if args[1] == "promote":
        if origin is not None or source_manager.wm_class == "kitty-agent":
            return
        origin = (source_manager.wm_class, source_tab.force_show_title_bars)
        app_id, header = "kitty-agent", True
    else:
        if origin is None:
            return
        app_id, header = origin

    os_window_id = boss.add_os_window(wclass=app_id)
    target_manager = boss.os_window_map[os_window_id]
    target_tab = target_manager.new_tab(empty_tab=True)
    target_tab.force_show_title_bars = header
    boss._move_window_to(window=window, target_tab_id=target_tab.id)

    if args[1] == "promote":
        window._agent_window_origin = origin
    else:
        del window._agent_window_origin
