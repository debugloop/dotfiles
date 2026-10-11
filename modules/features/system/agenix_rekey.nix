_: {
  flake.modules.nixos.agenix_rekey = {
    config,
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.agenix-rekey.nixosModules.default];

    age.rekey = {
      masterIdentities = [
        (inputs.self + "/keys/physical/desk.pub")
        (inputs.self + "/keys/physical/keychain.pub")
      ];
      agePlugins = [pkgs.age-plugin-fido2-hmac];
      storageMode = "local";
      localStorageDir = inputs.self + "/secrets/rekeyed/${config.networking.hostName}";
    };
  };
}
