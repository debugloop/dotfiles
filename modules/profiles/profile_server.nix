_: {
  flake.modules.nixos.profile_server = {
    config,
    inputs,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      node_exporter
      auto_upgrade
      auto_cleanup
    ];

    documentation.nixos.enable = false;
    users.users.${config.mainUser}.linger = true;

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.profile_server];
  };

  flake.modules.homeManager.profile_server = _: {
    services.ssh-agent.enable = true;
  };
}
