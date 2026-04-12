_: {
  flake.nixosModules.laptop_audio = {top, ...}: {
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

    home-manager.sharedModules = [top.homeModules.laptop_audio];
  };

  flake.homeModules.laptop_audio = {pkgs, ...}: {
    home.packages = with pkgs; [pamixer];
  };
}
