_: {
  flake.modules.nixos.server = {inputs, ...}: {
    imports = with inputs.self.modules.nixos; [
      host
      node_exporter
      auto_upgrade
      auto_cleanup
    ];
  };

  flake.modules.homeManager.server = {inputs, ...}: {
    imports = with inputs.self.modules.homeManager; [
      ssh_agent
    ];
  };
}
