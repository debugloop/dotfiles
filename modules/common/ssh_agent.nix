{...}: {
  flake.homeModules.ssh_agent = {...}: {
    services.ssh-agent.enable = true;
  };
}
