_: {
  flake.modules.nixos.zed = {
    inputs,
    config,
    ...
  }: {
    programs.nix-ld.enable = true;

    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".config/zed"
      ".local/share/zed"
    ];

    home-manager.sharedModules = [inputs.self.modules.homeManager.zed];
  };

  flake.modules.homeManager.zed = _: {
    programs.zed-editor.enable = true;
  };
}
