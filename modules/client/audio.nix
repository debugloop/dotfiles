_: {
  flake.modules.nixos.audio = {inputs, ...}: {
    services = {
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        wireplumber.enable = true;
      };
      speechd.enable = false;
    };

    security.rtkit.enable = true;

    environment.persistence."/nix/persist".users.danieln.directories = [
      ".local/state/wireplumber"
    ];

    home-manager.sharedModules = [inputs.self.modules.homeManager.audio];
  };

  flake.modules.homeManager.audio = {pkgs, ...}: {
    home.packages = with pkgs; [
      pamixer
      sox
    ];
  };
}
