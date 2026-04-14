_: {
  flake.modules.nixos.cache = {
    inputs,
    config,
    lib,
    ...
  }: let
    keyDir = inputs.self + "/keys/hosts";
    allKeys = builtins.readDir keyDir;
    otherPubKeys =
      lib.filterAttrs (
        name: _: lib.hasSuffix ".pub" name && name != "${config.networking.hostName}.pub"
      )
      allKeys;
  in {
    nix.sshServe = {
      enable = true;
      keys = map (name: builtins.readFile (keyDir + "/${name}")) (builtins.attrNames otherPubKeys);
    };
  };
}
