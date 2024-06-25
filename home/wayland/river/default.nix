{ config, pkgs, ... }:

{

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "river";
  };
  xdg.configFile = {
    "river-luatile/layout.lua".source = ./layout.lua;
  };
  wayland.windowManager.river = {
    enable = true;
    extraConfig = ''
      riverctl keyboard-layout -model pc105 -variant altgr-intl -options compose:rctrl,lv3:caps_switch us;

      ${pkgs.river-luatile}/bin/river-luatile &
    '';
    settings =
      let
        flow = with pkgs; (rustPlatform.buildRustPackage rec {
          pname = "flow";
          version = "v0.2.0";
          src = fetchFromGitHub {
            inherit pname version;
            owner = "stefur";
            repo = pname;
            rev = version;
            hash = "sha256-VVM6EuefMWlB3B6XUiGwx8MTmEIhPykLw0erdK1A5sE=";
          };
          nativeBuildInputs = [ ];
          buildInputs = [ ];
          cargoDepsName = pname;
          cargoLock = {
            lockFile = "${src}/Cargo.lock";
          };
        });
      in
      {
        background-color = "0x${config.colors.background}";
        border-color-focused = "0x${config.colors.blue}";
        border-color-unfocused = "0x${config.colors.light_bg}";
        border-color-urgent = "0x${config.colors.red}";
        border-width = 1;
        declare-mode = [
          "close"
          "locked"
          "normal"
          "passthrough"
          "suspend"
        ];
        default-attach-mode = "bottom";
        default-layout = "luatile";
        focus-follows-cursor = "normal";
        input = {
          # pointer-foo-bar = {
          #   accel-profile = "flat";
          #   events = true;
          #   pointer-accel = -0.3;
          #   tap = false;
          # };
        };
        map-pointer = {
          normal = {
            "Super BTN_LEFT" = "move-view";
            "Super BTN_RIGHT" = "resize-view";
            "Super BTN_MIDDLE" = "toggle-float";
          };
        };
        map = {
          close = {
            "None Escape" = "enter-mode normal";
            "None q" = "enter-mode normal";
            "Super c" = "spawn 'riverctl close & riverctl enter-mode normal'";
            "None c" = "spawn 'riverctl close & riverctl enter-mode normal'";
          };
          passthrough = {
            "Super Escape" = "enter-mode normal";
          };
          suspend = {
            "None Escape" = "enter-mode normal";
            "None q" = "enter-mode normal";
            "Super+Control Backslash" = "spawn 'systemctl suspend & riverctl enter-mode normal'";
          };
          normal = {
            # run
            "Super Return" = "spawn '${pkgs.kitty}/bin/kitty'";
            "None XF86Display" = "spawn '${pkgs.wdisplays}/bin/wdisplays'";

            # lock
            "Super Backslash" = "spawn '${pkgs.swaylock-effects}/bin/swaylock -f'";
            "None Cancel" = "spawn '${pkgs.swaylock-effects}/bin/swaylock -f'";

            # launcher
            "Super d" = ''spawn '${pkgs.wofi}/bin/wofi -G -p "" -S run';'';
            "Super+Control v" = "spawn '${pkgs.clipman}/bin/clipman pick -t wofi'";

            # notifications
            "Super n" = "spawn '${pkgs.mako}/bin/makoctl dismiss'";
            "Super+Shift n" = "spawn '${pkgs.mako}/bin/makoctl dismiss -a'";

            # screenshots
            # TODO: debug invalid geometry
            "None Print" = ''spawn 'fish -c "${pkgs.grim}/bin/grim -g $(${pkgs.slurp}/bin/slurp)"' '';
            "Shift Print" = "spawn '${pkgs.grim}/bin/grim'";

            # wm control
            "Super c" = "enter-mode close";
            "Super+Control Backslash" = "enter-mode suspend";
            "Super Escape" = "enter-mode passthrough";
            "Super Period" = "spawn '${pkgs.psmisc}/bin/killall -SIGUSR1 .waybar-wrapped'";

            # windows
            "Super f" = "toggle-fullscreen";
            "Super v" = "toggle-float";

            # layout
            "Super Right" = "send-layout-cmd luatile 'gravity_right()'";
            "Super Left" = "send-layout-cmd luatile 'gravity_left()'";
            "Super Apostrophe" = "send-layout-cmd luatile 'gravity_mirror()'";
            "Super BracketRight" = "send-layout-cmd luatile 'main_count_increase()'";
            "Super BracketLeft" = "send-layout-cmd luatile 'main_count_decrease()'";

            # resize
            "Super Down" = "send-layout-cmd luatile 'main_size_increase()'";
            "Super Up" = "send-layout-cmd luatile 'main_size_decrease()'";
            "Super XF86AudioRaiseVolume" = "send-layout-cmd luatile 'main_size_increase()'";
            "Super XF86AudioLowerVolume" = "send-layout-cmd luatile 'main_size_decrease()'";

            # focus
            "Super h" = "focus-view left";
            "Super j" = "focus-view down";
            "Super k" = "focus-view up";
            "Super l" = "focus-view right";

            # move
            "Super+Shift h" = "swap left";
            "Super+Shift j" = "swap down";
            "Super+Shift k" = "swap up";
            "Super+Shift l" = "swap right";

            # workspaces
            "Super+Control j" = "spawn '${flow}/bin/flow cycle-tags previous 10 -o'";
            "Super+Control k" = "spawn '${flow}/bin/flow cycle-tags next 10 -o'";
            "Super 1" = "spawn '${flow}/bin/flow toggle-tags 1'";
            "Super 2" = "spawn '${flow}/bin/flow toggle-tags 2'";
            "Super 3" = "spawn '${flow}/bin/flow toggle-tags 4'";
            "Super 4" = "spawn '${flow}/bin/flow toggle-tags 8'";
            "Super 5" = "spawn '${flow}/bin/flow toggle-tags 16'";
            "Super 6" = "spawn '${flow}/bin/flow toggle-tags 32'";
            "Super 7" = "spawn '${flow}/bin/flow toggle-tags 64'";
            "Super 8" = "spawn '${flow}/bin/flow toggle-tags 128'";
            "Super 9" = "spawn '${flow}/bin/flow toggle-tags 256'";
            "Super 0" = "spawn '${flow}/bin/flow toggle-tags 512'";
            "Super+Control 1" = "toggle-focused-tags 1";
            "Super+Control 2" = "toggle-focused-tags 2";
            "Super+Control 3" = "toggle-focused-tags 4";
            "Super+Control 4" = "toggle-focused-tags 8";
            "Super+Control 5" = "toggle-focused-tags 16";
            "Super+Control 6" = "toggle-focused-tags 32";
            "Super+Control 7" = "toggle-focused-tags 64";
            "Super+Control 8" = "toggle-focused-tags 128";
            "Super+Control 9" = "toggle-focused-tags 256";
            "Super+Control 0" = "toggle-focused-tags 512";
            "Super+Shift 1" = "set-view-tags 1";
            "Super+Shift 2" = "set-view-tags 2";
            "Super+Shift 3" = "set-view-tags 4";
            "Super+Shift 4" = "set-view-tags 8";
            "Super+Shift 5" = "set-view-tags 16";
            "Super+Shift 6" = "set-view-tags 32";
            "Super+Shift 7" = "set-view-tags 64";
            "Super+Shift 8" = "set-view-tags 128";
            "Super+Shift 9" = "set-view-tags 256";
            "Super+Shift 0" = "set-view-tags 512";

            # TODO: build DND binding and indicator for waybar?
            # fancy keys
            "None XF86AudioMicMute" = "spawn '${pkgs.avizo}/bin/volumectl -M0 -m toggle-mute && pkill -SIGRTMIN+4 waybar'";
            "None XF86AudioStop" = "spawn '${pkgs.playerctl}/bin/playerctl -p spotify stop'";

            # volume
            "None XF86AudioMute" = "spawn '${pkgs.avizo}/bin/volumectl -M0 toggle-mute && pkill -SIGRTMIN+4 waybar'";
            "None XF86AudioRaiseVolume" = "spawn '${pkgs.avizo}/bin/volumectl -M0 up 1 && pkill -SIGRTMIN+4 waybar'";
            "None XF86AudioLowerVolume" = "spawn '${pkgs.avizo}/bin/volumectl -M0 down 1 && pkill -SIGRTMIN+4 waybar'";
            "Shift XF86AudioRaiseVolume" = "spawn '${pkgs.avizo}/bin/volumectl -M0 up 5 && pkill -SIGRTMIN+4 waybar'";
            "Shift XF86AudioLowerVolume" = "spawn '${pkgs.avizo}/bin/volumectl -M0 down 5 && pkill -SIGRTMIN+4 waybar'";
            "None XF86AudioPlay" = "spawn '${pkgs.playerctl}/bin/playerctl -p spotify play-pause'";
            "None XF86AudioNext" = "spawn '${pkgs.playerctl}/bin/playerctl -p spotify next'";
            "None XF86AudioPrev" = "spawn '${pkgs.playerctl}/bin/playerctl -p spotify previous'";

            # brightness
            "None XF86MonBrightnessUp" = "spawn '${pkgs.avizo}/bin/lightctl -M0 up 5'";
            "None XF86MonBrightnessDown" = "spawn '${pkgs.avizo}/bin/lightctl -M0 down 5'";
            "Shift XF86MonBrightnessUp" = "spawn '${pkgs.sudo}/bin/sudo ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 + 20'";
            "Shift XF86MonBrightnessDown" = "spawn '${pkgs.sudo}/bin/sudo ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 - 20'";
          };
        };
        rule-add = {
          "-app-id" = {
            "'*'" = "ssd";
          };
        };
        # set-cursor-warp = "on-output-change";
        # set-repeat = "50 300";
        spawn = [
          # "firefox"
          # "'foot -a terminal'"
        ];
      };
  };
}
