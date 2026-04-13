_: {
  flake.homeModules.ssh_agent = _: {
    services.ssh-agent.enable = true;
  };
}
