_: {
  flake.modules.nixos.usb_wake = _: {
    services.udev.extraRules = ''
      # Let USB reconnection wake the system through USB 2.0 root hubs.
      ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", KERNEL=="usb*", ATTR{idVendor}=="1d6b", ATTR{idProduct}=="0002", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"

      # Let the TOTEM keyboard wake the system from suspend.
      ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="1d50", ATTR{idProduct}=="615e", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"

      # Let the Magic Trackpad wake the system from suspend.
      ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="05ac", ATTR{idProduct}=="0324", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
    '';
  };
}
