_: {
  flake.modules.nixos.server = {inputs, ...}: {
    imports = with inputs.self.modules.nixos; [
      host
      basicauth
      node_exporter
      auto_upgrade
      auto_cleanup
    ];

    home-manager.users.danieln.imports = [inputs.self.modules.homeManager.server];
  };

  flake.modules.homeManager.server = {inputs, ...}: {
    imports = with inputs.self.modules.homeManager; [
      ssh_agent
    ];
  };
}
