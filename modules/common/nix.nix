{ ... }: {
  flake.modules.nixos.common_nix = {inputs, ...}: {
    imports = [
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
    ];

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = ["@wheel"];
      };
    };

    nixpkgs = {
      hostPlatform = "x86_64-linux";
      config = {
        allowUnfree = true;
        warnUndeclaredOptions = true;
      };
      overlays = [
        # inputs.neovim-nightly-overlay.overlays.default
      ];
    };

    age.secrets = {
      password.file = ../../secrets/password.age;
    };
  };
}
