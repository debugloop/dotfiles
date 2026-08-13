_: {
  flake.modules.nixos.magic_trackpad = _: {
    powerManagement.resumeCommands = ''
      for device in /sys/bus/usb/devices/*; do
        [ -f "$device/idVendor" ] || continue
        read -r vendor < "$device/idVendor"
        [ "$vendor" = 05ac ] || continue
        read -r product < "$device/idProduct"
        [ "$product" = 0324 ] || continue

        name="''${device##*/}"
        case "$name" in
          *.*)
            parent="''${name%.*}"
            port="''${name##*.}"
            ;;
          *-*)
            bus="''${name%%-*}"
            parent="usb$bus"
            port="''${name##*-}"
            ;;
          *) continue ;;
        esac

        disable="/sys/bus/usb/devices/$parent:1.0/$parent-port$port/disable"
        [ -e "$disable" ] || continue

        echo 1 > "$disable"
        sleep 2
        echo 0 > "$disable"
      done
    '';
  };
}
