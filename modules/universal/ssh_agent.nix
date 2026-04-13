_: {
  flake.modules.homeManager.ssh_agent = _: {
    services.ssh-agent.enable = true;
  };
}
