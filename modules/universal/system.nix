_: {
  flake.modules.nixos.system = {
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
      nixos-generators

      # hardware support
      efibootmgr
      xfsprogs
    ];

    documentation.man.cache.enable = false;
  };
}
