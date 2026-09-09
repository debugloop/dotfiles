_: {
  flake.modules.nixos.voxtype = {
    config,
    inputs,
    ...
  }: {
    users.users.${config.mainUser}.extraGroups = ["input"];

    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".local/share/voxtype/models"
    ];

    backup.exclude = [
      "home/${config.mainUser}/.local/share/voxtype/models"
    ];

    home-manager.users.${config.mainUser}.imports = [inputs.self.modules.homeManager.voxtype];
  };

  flake.modules.homeManager.voxtype = {
    lib,
    pkgs,
    ...
  }: {
    services.voxtype = {
      enable = true;
      # On lusus, Vulkan was 5.6 times faster with a cold cache.
      # It was 19.6 times faster with a warm cache. Test Vulkan on simmons when possible.
      package = pkgs.voxtype-vulkan;
      loadModels = ["base.en"];

      settings = {
        hotkey = {
          enabled = true;
          key = "F13";
          mode = "push_to_talk";
        };

        whisper = {
          model = "base.en";
          language = "en";
        };

        output = {
          mode = "type";
          fallback_to_clipboard = true;
          wait_for_modifier_release = true;
        };
      };
    };

    systemd.user.services.voxtype = {
      Unit = {
        After = ["graphical-session.target"];
        PartOf = lib.mkForce ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
      };
      Install.WantedBy = lib.mkForce ["graphical-session.target"];
    };
  };
}
