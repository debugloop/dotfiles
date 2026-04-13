_: {
  flake.nixosModules.server = {top, ...}: {
    imports = with top.nixosModules; [
      host
      node_exporter
      auto_upgrade
      auto_cleanup
    ];
  };

  flake.homeModules.server = {top, ...}: {
    imports = with top.homeModules; [
      ssh_agent
    ];
  };
}
