_: {
  flake.modules.nixos.gh = {config, ...}: {
    # `gh auth login` puts the token in the gnome keyring (already persisted by
    # the desktop module) and keeps only the active host and account here. Both
    # halves are needed: without hosts.yml gh does not know which account the
    # keyring entry belongs to and asks for a new login on every boot.
    environment.persistence."/nix/persist".users.${config.mainUser} = {
      files = [".config/gh/hosts.yml"];
    };
  };

  flake.modules.homeManager.gh = {pkgs, ...}: {
    programs.gh = {
      enable = true;
      extensions = [
        # nixpkgs still ships 0.0.4, which drives the stack API through the
        # internal endpoints that only accept a personal access token. 0.1.0
        # moved to the public /repos/{owner}/{repo}/stacks REST API and works
        # with the normal `gh auth login` token. Drop this override once
        # nixpkgs reaches 0.1.0.
        (pkgs.gh-stack.overrideAttrs (final: prev: {
          version = "0.1.0";
          src = pkgs.fetchFromGitHub {
            owner = "github";
            repo = "gh-stack";
            tag = "v${final.version}";
            hash = "sha256-48JkOeqbvHlCZ2u3LnwJymw55xMQWLTPJLDbV44clGI=";
          };
          vendorHash = "sha256-0Xtr/MOpX4u5GnbRdNxKPA0GpSzi8PIbVc9MmP05De4=";
          # The rebase tests added in 0.1.0 shell out to git.
          nativeCheckInputs = (prev.nativeCheckInputs or []) ++ [pkgs.git];
        }))
      ];
      settings = {
        version = 1;
        git_protocol = "ssh";
      };
    };
  };
}
