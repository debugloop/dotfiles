_: {
  flake.modules.nixos.hister_work = {inputs, ...}: {
    imports = [inputs.self.modules.nixos.hister];

    services.hister.settings.app.search_url = "https://hister.bugpara.de/?q={query}";
  };
}
