_: {
  flake.modules.nixos.flatpak = {config, ...}: {
    services.flatpak.enable = true;

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/flatpak"
      ];
      users.${config.mainUser}.directories = [
        ".var/app"
        ".local/share/flatpak"
      ];
    };

    backup.exclude = [
      "var/lib/flatpak"
      "home/${config.mainUser}/.var" # flatpak data
      "home/${config.mainUser}/.local/share/flatpak"
    ];
  };
}
