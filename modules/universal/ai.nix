_: {
  flake.modules.homeManager.ai = {pkgs, ...}: {
    programs = {
      opencode.enable = true;
      claude-code.enable = true;

      # CLAUDE_CONFIG_DIR consolidates .claude.json into ~/.claude/ so the single
      # virtiofs-mounted dir covers all claude state in both host and microvms
      fish.shellInit = ''
        set -x CLAUDE_CONFIG_DIR /home/danieln/.claude
      '';
    };

    home.packages = with pkgs; [github-copilot-cli];
  };
}
