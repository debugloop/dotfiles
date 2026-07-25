{inputs, ...}: {
  flake.modules.nixos.wallpaper = {
    age.secrets.wall = {
      file = inputs.self + "/secrets/wall.age";
      mode = "0444";
    };
    home-manager.sharedModules = [inputs.self.modules.homeManager.wallpaper];
  };
  flake.modules.homeManager.wallpaper = {
    services.awww.enable = true;
    programs.niri.settings.spawn-at-startup = [
      {argv = ["awww" "img" "/run/agenix/wall"];}
    ];
  };
}
