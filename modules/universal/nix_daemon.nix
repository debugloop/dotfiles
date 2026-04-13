_: {
  flake.modules.nixos.nix_daemon = {
    nix.settings = {
      experimental-features = "nix-command flakes";
      trusted-users = ["@wheel"];
    };
  };
}
