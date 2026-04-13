_: {
  flake.nixosModules.software = {
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
        bridge-utils
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

    documentation.man.cache.enable = false;

    programs = {
      fish.enable = true;
      mtr.enable = true;
      traceroute.enable = true;
    };

    services = {
      dbus.enable = true;
    };
  };
}
