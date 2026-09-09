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
  }: let
    voxtypePackage = pkgs.voxtype-vulkan;
  in {
    services.voxtype = {
      enable = true;
      # On lusus, Vulkan was 5.6 times faster with a cold cache.
      # It was 19.6 times faster with a warm cache. Test Vulkan on simmons when possible.
      package = voxtypePackage;
      loadModels = ["small.en"];
      environment = {
        PATH = lib.makeBinPath [voxtypePackage pkgs.quickshell];
        QT_SCALE_FACTOR = "1.25";
        VOXTYPE_OSD_QML_PATH = "${voxtypePackage.src}/quickshell";
      };

      settings = {
        hotkey = {
          enabled = true;
          key = "F13";
          mode = "push_to_talk";
        };

        whisper = {
          model = "small.en";
          language = "en";
          initial_prompt = "NixOS, Nix, Home Manager, Neovim, Niri, Wayland, systemd, Kubernetes, TypeScript, Voxtype, pi.";
        };

        osd = {
          enabled = true;
          frontend = "quickshell";
        };

        output = {
          mode = "type";
          fallback_to_clipboard = true;
          wait_for_modifier_release = true;
          notification.on_transcription = false;
        };

        text.smart_auto_submit = true;
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
