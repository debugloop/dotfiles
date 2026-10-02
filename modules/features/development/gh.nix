_: {
  flake.modules.nixos.gh = {config, ...}: {
    # `gh auth login` stores the token in the Gnome keyring. The desktop module
    # persists the keyring. It stores the account metadata and settings here.
    environment.persistence."/nix/persist".users.${config.mainUser} = {
      files = [
        ".config/gh/config.yml"
        ".config/gh/hosts.yml"
      ];
    };
  };

  flake.modules.homeManager.gh = {pkgs, ...}: {
    # The gh module generates a read-only config.yml. Disable that file so gh
    # can update the persisted copy.
    xdg.configFile."gh/config.yml".enable = false;

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
    };
  };
}
