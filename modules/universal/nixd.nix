_: {
  flake.modules.nixos.nixd = {
    nix.settings = {
      experimental-features = "nix-command flakes";
      trusted-users = ["@wheel"];
    };
  };
}
