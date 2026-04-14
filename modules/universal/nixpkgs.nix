_: {
  flake.modules.nixos.nixpkgs = {lib, ...}: {
    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
      config = {
        allowUnfree = true;
        warnUndeclaredOptions = true;
      };
      overlays = [
        # inputs.neovim-nightly-overlay.overlays.default
      ];
    };
  };
}
