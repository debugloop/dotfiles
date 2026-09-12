_: {
  flake.modules.nixos.hister_personal = {
    config,
    inputs,
    ...
  }: {
    imports = [inputs.self.modules.nixos.hister];

    services = {
      hister = {
        environmentFile = config.age.secrets.hister.path;
        settings.server.base_url = "https://hister.bugpara.de";
      };

      caddy.virtualHosts."hister.bugpara.de".extraConfig = ''
        reverse_proxy localhost:4433
      '';
    };

    age.secrets.hister = {
      file = inputs.self + "/secrets/hister.age";
      owner = config.services.hister.user;
      group = config.services.hister.group;
      mode = "0400";
    };
  };
}
