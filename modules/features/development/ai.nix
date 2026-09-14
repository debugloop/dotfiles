_: {
  flake.modules.nixos.ai = {config, ...}: {
    # Persist mutable AI-tool state across reboots (root is tmpfs).
    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".pi"
      ".agents"
    ];
  };

  flake.modules.homeManager.ai = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.pi-coding-agent = {
      enable = true;

      # pi installs npm/git packages at runtime, so it needs node + npm on PATH.
      extraPackages = [pkgs.nodejs];

      # AGENTS.md — global context (read-only store symlink).
      context = ''
        * When the conversation has multiple threads or topics, or if providing multiple alternatives: Pick a numbered identifier per item for the user to refer back to. If multiple sections need identifiers, prefix the number with a letter.
        * Ask one clarification question at a time. If a response needs several user decisions, label them A1, A2, B1, and so on, so `/answer` can present the relevant items in order.
        * If asked to implement something that does not appear to be idiomatic or optimal in some way, notify the user about your doubts. The user is grateful for the opportunity to defend their decisions and improve their judgement, especially if your objections are justified and well thought out.
        * For prose that you add to a repository, use the `ste-writing` skill in STE-flavored mode. Apply this especially to comments and documentation intended for commit.
        * Your own config (skills, extensions, settings) is Nix-managed: Files under ~/.pi and ~/.agents might be store symlinks. If you need to change one and hit a read-only path, suggest a fork for testing and later reconciliation, or edit the source under ${config.dotfiles.root} (typically modules/features/development/pi/ or ai.nix). Never edit the symlink target in place.
        * Editor access is opt-in. Do not discover, inspect, or modify editor state unless the current task refers to editor context. Editor context includes visible, selected, or open content, or a mention of Neovim, nvim, Vim, or an editor. Without editor context, use disk tools.
      '';
    };

    home.packages = with pkgs; [
      htmlq
      nodejs
    ];

    # Agent content pi loads from ~/.pi (+ tool-agnostic skills from ~/.agents).
    # Runtime-added skills/extensions land under other names and persist via the
    # impermanence entry above.
    #
    # Live symlinks point out-of-store into the repo, so edits (by you, an agent,
    # or pi at runtime) reflect straight back into the checkout as a git diff.
    # Store-built entries are read-only; changing them needs a `switch`.
    home.file = let
      # Home-relative form, for home.file attr names keyed relative to $HOME.
      piConfigDirRel =
        lib.removePrefix "${config.home.homeDirectory}/"
        config.programs.pi-coding-agent.configDir;

      piExtensionsSrc = ./pi/extensions;

      # Non-SDK deps for forked extensions, built from package-lock.json.
      piExtensionsNodeModules = pkgs.importNpmLock.buildNodeModules {
        npmRoot = piExtensionsSrc;
        inherit (pkgs) nodejs;
      };

      # Store tree: extension sources + node_modules adjacent. Seeded as ordinary
      # store symlinks, so Node's realpath walk-up resolves deps here — no
      # repo-side node_modules. Editing a forked extension needs `switch`.
      piExtensionsTree = pkgs.runCommand "pi-extensions-tree" {} ''
        cp -r ${piExtensionsSrc} "$out"
        chmod -R u+w "$out"
        rm -f "$out"/node_modules
        ln -s ${piExtensionsNodeModules}/node_modules "$out/node_modules"
      '';

      # Auto-discovered from the skills / extensions dirs.
      skills =
        builtins.filter
        (name: builtins.pathExists "${./pi/skills}/${name}/SKILL.md")
        (builtins.attrNames (builtins.readDir ./pi/skills));

      extensions =
        builtins.filter
        (name: (builtins.readDir ./pi/extensions).${name} == "directory")
        (builtins.attrNames (builtins.readDir ./pi/extensions));
    in
      {
        # Settings: live symlinks so pi's runtime writes land in repo files
        # (git diffs) instead of silently diverging from Nix.
        "${piConfigDirRel}/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.root}/modules/features/development/pi/settings.json";
        "${piConfigDirRel}/extensions/pi-tool-display/config.json".source =
          config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.root}/modules/features/development/pi/tool-display.json";

        # Deps: jiti resolves extension deps from this symlink's logical parent,
        # not the store realpath, so the shared node_modules must live beside them.
        "${piConfigDirRel}/extensions/node_modules".source = "${piExtensionsNodeModules}/node_modules";
      }
      # Skills: tool-agnostic, live symlinks — agents read them, you edit them.
      // builtins.listToAttrs (map (skill: {
          name = ".agents/skills/${skill}";
          value.source =
            config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.root}/modules/features/development/pi/skills/${skill}";
        })
        skills)
      # Extensions: our forked/custom extensions, store-built from repo source.
      // builtins.listToAttrs (map (ext: {
          name = "${piConfigDirRel}/extensions/${ext}";
          value.source = "${piExtensionsTree}/${ext}";
        })
        extensions);
  };
}
