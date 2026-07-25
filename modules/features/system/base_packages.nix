_: {
  flake.modules.nixos.base_packages = {
    pkgs,
    inputs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
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

      # hardware support
      efibootmgr
      xfsprogs
    ];

    documentation.man.cache.enable = false;
  };
}
