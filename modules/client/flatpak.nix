_: {
  flake.nixosModules.flatpak = {
    services.flatpak.enable = true;

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/flatpak"
      ];
      users.danieln.directories = [
        ".var/app"
        ".local/share/flatpak"
      ];
    };

    backup.exclude = [
      "var/lib/flatpak"
      "home/danieln/.var" # flatpak data
      "home/danieln/.local/share/flatpak"
    ];
  };
}
