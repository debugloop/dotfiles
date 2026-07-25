_: {
  flake.modules.homeManager.dotfiles = {lib, ...}: {
    options.dotfiles.root = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos";
      description = "Absolute path to the mutable dotfiles checkout.";
    };
  };
}
