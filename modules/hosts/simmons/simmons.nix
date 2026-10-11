{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.simmons = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };
    modules = [self.modules.nixos.simmons];
  };

  flake.modules.nixos.simmons = {
    config,
    inputs,
    ...
  }: {
    imports =
      (with inputs.self.modules.nixos; [
        profile_base
        profile_client
        profile_development
        tailscale_personal
      ])
      ++ [./_hardware-configuration.nix];

    networking.hostName = "simmons";

    age.rekey.hostPubkey = ../../../keys/hosts/simmons.pub;

    boot.initrd.systemd.fido2.enable = true;
    boot.initrd.luks.devices.crypt.crypttabExtraOpts = [
      "fido2-device=auto"
      "token-timeout=5s"
    ];

    home-manager.users.${config.mainUser}.home.stateVersion = "26.05";

    backup = {
      enable = true;
      storagebox = import ../../features/storage/storagebox/_simmons.nix;
    };
    system.stateVersion = "26.05";

    programs = {
      gamemode.enable = true;
      steam.enable = true;
    };
  };
}
