_: {
  flake.modules.nixos.udev = {pkgs, ...}: {
    services.udev = {
      packages = [pkgs.libmtp.out];
      extraRules = ''
        # generic stm32 keyboard flashing
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666"

        # fazua ebike integration
        SUBSYSTEM!="usb|usb_device", GOTO="ebike_rules_end"
        ACTION!="add", GOTO="ebike_rules_end"
        # 10c4:1000 for E-Bike Bootloader mode
        ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="1000", MODE="0666", SYMLINK+="ebike-bootloader-%n"
        # 10c4:100X for E-Bikes regular operation
        ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="1001", MODE="0666", SYMLINK+="ebike-brain-%n"
        # 10c4:100X for Lola device
        ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="1002", MODE="0666", SYMLINK+="lola-%n"
        LABEL="ebike_rules_end"
      '';
    };
  };
}
