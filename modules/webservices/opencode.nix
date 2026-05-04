_: {
  flake.modules.nixos.opencode = {
    config,
    inputs,
    ...
  }: {
    home-manager.sharedModules = [inputs.self.modules.homeManager.opencode];

    environment.persistence."/nix/persist".users.${config.mainUser} = {
      directories = [
        ".config/opencode"
        ".local/share/opencode"
      ];
    };

    services.caddy.virtualHosts."ai.bugpara.de".extraConfig = ''
      basicauth * {
        ${config.webservices.basicauth}
      }
      reverse_proxy localhost:4096
    '';
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
          "127.0.0.1"
          "--port"
          "4096"
        ];
      };
    };

    systemd.user.services.opencode-web.Service.WorkingDirectory = "${config.home.homeDirectory}/code";
  };
}
