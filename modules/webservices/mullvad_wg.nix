_: {
  flake.modules.nixos.mullvad_wg = {
    config,
    inputs,
    ...
  }: {
    networking.wg-quick.interfaces.mullvad.configFile = "${config.age.secrets.mullvad-conf.path}";
    age.secrets.mullvad-conf.file = inputs.self + "/secrets/mullvad.conf.age";
  };
}
