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

    home-manager.sharedModules = [inputs.self.modules.homeManager.theme];
  };

  flake.modules.homeManager.theme = {pkgs, ...}: {
    gtk = {
      enable = true;
      gtk4.theme = null;
    };

    home = {
      pointerCursor = {
        package = "${pkgs.numix-cursor-theme}";
        name = "Numix-Cursor";
        gtk.enable = true;
      };
      sessionVariables = {
        GTK_THEME = "Arc-Darker";
      };
      packages = with pkgs; [
        arc-theme
        gnome-icon-theme
      ];
    };
  };
}
