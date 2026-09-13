_: {
  flake.modules.nixos.theme = {
    config,
    inputs,
    ...
  }: {
    environment.persistence."/nix/persist".users.${config.mainUser} = {
      directories = [
        ".config/gtk-3.0"
      ];
    };

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.theme];
  };

  flake.modules.homeManager.theme = {pkgs, ...}: {
    gtk = {
      enable = true;
      colorScheme = "dark";
      gtk3.theme = {
        name = "io.elementary.stylesheet.slate";
        package = pkgs.pantheon.elementary-gtk-theme;
      };
      gtk4.theme = null;
    };

    home = {
      pointerCursor = {
        enable = true;
        package = "${pkgs.numix-cursor-theme}";
        name = "Numix-Cursor";
        gtk.enable = true;
      };
      packages = with pkgs; [
        pantheon.elementary-icon-theme
      ];
    };
  };
}
