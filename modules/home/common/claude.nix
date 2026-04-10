{...}: {
  programs.claude-code.enable = true;

  # CLAUDE_CONFIG_DIR consolidates .claude.json into ~/.claude/ so the single
  # virtiofs-mounted dir covers all claude state in both host and microvms
  programs.fish.shellInit = ''
    set -x CLAUDE_CONFIG_DIR /home/danieln/.claude
  '';
}
