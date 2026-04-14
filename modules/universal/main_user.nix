_: {
  flake.modules.nixos.main_user = {lib, ...}: {
    options.mainUser = lib.mkOption {
      type = lib.types.str;
      description = "The primary user account name.";
    };
  };
}
