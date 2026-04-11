{ ... }: {
  flake.modules.home.server_base = {...}: {
    services.ssh-agent.enable = true;
  };
}
