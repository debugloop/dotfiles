_: {
  flake.modules.nixos.software = {
    pkgs,
    inputs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
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
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      nixos-generators

      # hardware support
      efibootmgr
      xfsprogs
    ];

    documentation.man.cache.enable = false;

    programs = {
      mtr.enable = true;
      traceroute.enable = true;
    };
  };
}
