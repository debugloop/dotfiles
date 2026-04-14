_: {
  flake.modules.nixos.mullvad = _: {
    services.mullvad-vpn.enable = true;

    environment.persistence."/nix/persist".directories = [
      "/etc/mullvad-vpn"
    ];
  };
}
