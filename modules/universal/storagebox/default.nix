_: {
  flake.modules.nixos.storagebox = {
    config,
    lib,
    ...
  }: let
    accounts = {
      roshar = import ./_roshar.nix;
      simmons = import ./_simmons.nix;
    };
    account = accounts.${config.networking.hostName} or null;
  in {
    config = lib.mkIf (account != null) {
      backup.storagebox = {
        inherit (account) host user;
      };
    };
  };
}
