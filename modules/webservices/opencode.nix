_: {
  flake.modules.nixos.opencode = {
    inputs,
    config,
    ...
  }: {
    home-manager.sharedModules = [inputs.self.modules.homeManager.opencode];

    environment.persistence."/nix/persist".users.${config.mainUser} = {
      directories = [
        ".config/opencode"
        ".local/share/opencode"
      ];
    };
  };

  flake.modules.homeManager.opencode = {
    config,
    lib,
    ...
  }: {
    programs.opencode = {
      enable = lib.mkDefault true;
      web = {
        enable = true;
        extraArgs = [
          "--hostname"
          "0.0.0.0"
          "--port"
          "4096"
        ];
      };
    };

    systemd.user.services.opencode-web.Service = {
      WorkingDirectory = "${config.home.homeDirectory}/code";
      Environment = "PATH=/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin";
    };
  };
}
