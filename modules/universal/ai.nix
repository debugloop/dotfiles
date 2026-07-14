_: {
  flake.modules.nixos.ai = {config, ...}: {
    # Persist mutable AI-tool state across reboots (root is tmpfs).
    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".claude"
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
    programs = {
      claude-code.enable = true;
      pi-coding-agent = {
        enable = true;

        # pi installs npm/git packages at runtime, so it needs node + npm on PATH.
        extraPackages = [pkgs.nodejs];

        # AGENTS.md — global context (read-only store symlink).
        context = ''
          * When the conversation has multiple threads or topics, or if providing multiple alternatives: Pick a numbered identifier per item for the user to refer back to. If multiple sections need identifiers, prefix the number with a letter.
          * Use the question/answer tooling to clarify whenever sensible, it avoids excessive numbered identifier reliance.
          * If asked to implement something that does not appear to be idiomatic or optimal in some way, notify the user about your doubts. The user is grateful for the opportunity to defend their decisions and improve their judgement, especially if your objections are justified and well thought out.
          * Your own config (skills, extensions, settings) is Nix-managed: Files under ~/.pi and ~/.agents might be store symlinks. If you need to change one and hit a read-only path, suggest a fork for testing and later reconciliaton, or to edit the source in /etc/nixos (typically modules/universal/pi/ or ai.nix). Never edit the symlink target in place.
          * Neovim vs disk edits: Use Neovim tools for loaded buffers and editor-context work (cursor/selection/viewport, unsaved changes, diagnostics, LSP rename/actions, undo integration). Use disk edit tools for unloaded files and broad patch-oriented changes. Saving Neovim buffers is allowed, but saves may trigger autoformat/autocmds; after saving, assume buffer contents, cursor positions, line numbers, diagnostics, and other editor state may have changed, then re-check state/diagnostics before further edits.
        '';
      };

      # CLAUDE_CONFIG_DIR consolidates .claude.json into ~/.claude/ so the single
      # virtiofs-mounted dir covers all claude state in both host and microvms
      fish.shellInit = ''
        set -x CLAUDE_CONFIG_DIR ${config.home.homeDirectory}/.claude
      '';
    };

    home.packages = with pkgs; [
      github-copilot-cli
      nodejs
    ];

    # Agent content pi loads from ~/.pi (+ tool-agnostic skills from ~/.agents).
    # Runtime-added skills/extensions land under other names and persist via the
    # impermanence entry above.
    #
    # Live symlinks point out-of-store into the repo, so edits (by you, an agent,
    # or pi at runtime) reflect straight back into /etc/nixos as a git diff.
    # Store-built entries are read-only; changing them needs a `switch`.
    home.file = let
      repoRoot = "/etc/nixos";

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
        # Settings: live symlink so pi's runtime writes land in the repo file
        # (git diff) instead of silently diverging from Nix.
        "${piConfigDirRel}/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${repoRoot}/modules/universal/pi/settings.json";

        # Deps: jiti resolves extension deps from this symlink's logical parent,
        # not the store realpath, so the shared node_modules must live beside them.
        "${piConfigDirRel}/extensions/node_modules".source = "${piExtensionsNodeModules}/node_modules";
      }
      # Skills: tool-agnostic, live symlinks — agents read them, you edit them.
      // builtins.listToAttrs (map (skill: {
          name = ".agents/skills/${skill}";
          value.source =
            config.lib.file.mkOutOfStoreSymlink "${repoRoot}/modules/universal/pi/skills/${skill}";
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
