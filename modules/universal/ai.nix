_: {
  flake.modules.nixos.ai = {config, ...}: {
    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      ".claude"
    ];
  };

  flake.modules.homeManager.ai = {
    config,
    pkgs,
    ...
  }: {
    programs = {
      opencode = {
        enable = true;
        context = ''
          * When the conversation has multiple threads or topics, or if providing multiple alternative: Pick a
            numbered identifier per item for the user to refer back to. If multiple sections need idengifiers, prefix
            the number with a letter.
          * Use the question tool to clarify whenever sensible, it avoids excessive numbered identifier reliance. E.g.
            never ask inline whether the user is ready to proceed/implement, but rather use a question.
          * Be exact in the way you follow instructions, do not jump into implementation necessarily even if you are in
            build mode.
          * If asked to implement something that does not appear to be idiomatic or optimal in some way, notify the user
            about your doubts. The user is grateful for the opportunity to defend their decisions and improve their
            judgement, especially if your objections are justified and well thought out.
        '';
      };
      claude-code.enable = true;

      # CLAUDE_CONFIG_DIR consolidates .claude.json into ~/.claude/ so the single
      # virtiofs-mounted dir covers all claude state in both host and microvms
      fish.shellInit = ''
        set -x CLAUDE_CONFIG_DIR ${config.home.homeDirectory}/.claude
      '';
    };

    home.packages = with pkgs; [github-copilot-cli];
  };
}
