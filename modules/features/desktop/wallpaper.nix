{inputs, ...}: {
  flake.modules.nixos.wallpaper = {config, ...}: {
    age.secrets.wall = {
      file = inputs.self + "/secrets/wall.age";
      mode = "0444";
    };
    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.wallpaper];
  };
  flake.modules.homeManager.wallpaper = {
    services.awww.enable = true;
    programs.niri.settings.spawn-at-startup = [
      {argv = ["awww" "img" "/run/agenix/wall"];}
    ];
  };
}
