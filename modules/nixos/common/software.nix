{
  pkgs,
  inputs,
  ...
}: {
  environment = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      # root stuff
      coreutils
      file
      mkpasswd
      nettools
      pciutils
      procps
      psmisc
      usbutils

      # nix
      inputs.agenix.packages.x86_64-linux.default
      nixos-generators

      # hardware support
      efibootmgr
      xfsprogs
    ];
  };

  documentation.man.generateCaches = false;

  programs = {
    fish.enable = true;
    mtr.enable = true;
    traceroute.enable = true;
  };

  services = {
    dbus.enable = true;
  };
}
