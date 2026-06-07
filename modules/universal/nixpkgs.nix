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
        (_final: prev: {
          opencode = prev.opencode.overrideAttrs (old: rec {
            version = "1.15.5";
            src = prev.fetchFromGitHub {
              owner = "anomalyco";
              repo = "opencode";
              tag = "v${version}";
              hash = "sha256-HZiqia9QzkJMfRQ6bzFBsiGXNHv1WFLUdwhekE+rXM8=";
            };
            node_modules = old.node_modules.overrideAttrs (_: {
              inherit version src;
              outputHash = "sha256-lxwxaFTgonMPIe2GweEVZhCMSUN/quBgV1wvV05U5wc=";
            });
          });
        })
      ];
    };
  };
}
