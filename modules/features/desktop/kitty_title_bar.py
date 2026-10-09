from kittens.tui.handler import result_handler
from kitty.fast_data_types import get_options


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    if len(args) != 2 or args[1] not in {"show", "hide", "toggle"}:
        raise ValueError("Usage: kitten kitty_title_bar.py show|hide|toggle")

    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    tab = window.tabref()
    if tab is None:
        return
    min_windows = get_options().window_title_bar_min_windows
    if min_windows == 1:
        return
    manager = tab.tab_manager_ref()
    if manager is not None and manager.wm_class == "kitty-agent":
        tab.force_show_title_bars = True
        tab.relayout()
        return
    if min_windows != 0:
        raise ValueError("Set window_title_bar_min_windows to 0 to use this helper.")

    tab.force_show_title_bars = (
        not tab.force_show_title_bars if args[1] == "toggle" else args[1] == "show"
    )
    tab.relayout()
