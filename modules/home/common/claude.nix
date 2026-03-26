{...}: {
  programs.claude-code.enable = true;

  home.persistence."/nix/persist" = {
    directories = [".claude"];
    files = [".claude.json"];
  };
}
