{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      git
      tig
      (rustPlatform.buildRustPackage
        rec {
          pname = "mergiraf";
          version = "0.2.0";

          src = fetchFromGitea {
            domain = "codeberg.org";
            owner = "mergiraf";
            repo = "mergiraf";
            rev = "v${version}";
            sha256 = "sha256-egtX2daCbPXi5rX2OxbEZA/VI9R4HMj5LRKbUEBFo+E=";
          };
          nativeBuildInputs = [
            git
          ];
          cargoLock = {
            lockFile = "${src}/Cargo.lock";
            outputHashes = {
              "tree-sitter-go-0.23.1" = "sha256-elPqkvVYs0vADOuN/umDteWP5hqcXhQAoSkqYDtTxaU=";
              "tree-sitter-xml-0.7.0" = "sha256-RTWvOUAs3Uql9DKsP1jf9FZZHaZORE40GXd+6g6RQZw=";
              "tree-sitter-yaml-0.6.1" = "sha256-gS+SjOnGl/86U9VV/y1ca7naYIe7DAOvOv++jCRLTKo=";
            };
          };

          meta = with lib; {
            description = "A syntax-aware git merge driver for a growing collection of programming languages and file formats.";
            homepage = "https://codeberg.org/mergiraf/mergiraf";
            license = licenses.gpl3;
            maintainers = [];
          };
        })
    ];
    file = {
      ".gitignore".text = ''
        .session.nvim
      '';
      ".gitattributes".text = ''
        *.java merge=mergiraf
        *.rs merge=mergiraf
        *.go merge=mergiraf
        *.js merge=mergiraf
        *.jsx merge=mergiraf
        *.json merge=mergiraf
        *.yml merge=mergiraf
        *.yaml merge=mergiraf
        *.html merge=mergiraf
        *.htm merge=mergiraf
        *.xhtml merge=mergiraf
        *.xml merge=mergiraf
        *.c merge=mergiraf
        *.h merge=mergiraf
        *.cpp merge=mergiraf
        *.hpp merge=mergiraf
        *.cs merge=mergiraf
      '';
    };
  };
  programs.git = {
    enable = true;
    userName = "Daniel Nägele";
    userEmail = "git@danieln.de";
    delta = {
      enable = true;
      options = {
        navigate = "true";
        syntax-theme = "ansi";
        file-style = "omit";
        hunk-header-style = "file line-number syntax";
        hunk-header-decoration-style = "blue ul box";
      };
    };
    difftastic = {
      enable = false;
      background = "dark";
    };
    aliases = {
      # shorthands for daily stuff
      a = "add";
      amend = "commit --amend --no-edit";
      b = "branch --color='always' --sort=-authordate --format='%(color:yellow)%(refname:short)\ %(color:green)%(committerdate:relative)\ %(color:blue)%(authorname)'";
      bv = "branch --color='always' --sort=-authordate --format='%(color:yellow)%(refname:short)\ %(color:green)%(committerdate:relative)\ %(color:blue)%(authorname)\ %(color:reset)%(contents:subject)'";
      ci = "commit";
      ch = "cherry -v";
      d = "diff -w";
      ds = "-c delta.side-by-side=true d";
      dc = "d -- :^vendor :^go.mod :^go.sum";
      dsc = "-c delta.side-by-side=true dc";
      fixup = "commit --fixup";
      fi = "commit --fixup";
      l = "log --pretty=format:'%C(yellow)%h\ %C(green)%ad%Cred%d\ %Creset%s%Cblue\ [%an]' --date=relative -32";
      lg = "l --graph --boundary --cherry-mark";
      ld = "log --cherry --pretty=format:'%m\ %C(yellow)%h\ %C(green)%ad%Cred%d\ %Creset%s%Cblue\ [%an]' --date=relative -32";
      lp = "-c delta.side-by-side=true log --pretty=format:'%C(yellow)commit %h\ %C(green)%ad%Cred%d\ %Creset%s%Cblue\ [%an]' --date=relative -16 -p -- :^vendor :^go.mod :^go.sum"; # include "commit " for delta `n` navigation
      new = "l @{u}..";
      p = "pull --prune --all --autostash";
      puf = "push --force-with-lease --force-if-includes";
      rb = "rebase --autostash --autosquash";
      rba = "rebase --abort";
      rbc = "rebase --continue";
      s = "status --short";
      sh = "show --stat";
      sw = "switch";

      # repo path
      root = "rev-parse --show-toplevel"; # print root
      cr = "!f() {cd $(git rev-parse --show-toplevel)}"; # change to root
      exec = "!exec "; # make from wherever

      # files from index or from commits
      f = "!f() {
        if [ -z \"$1\" ]; then
          git ls-files -dmo
        else
          git show -m --pretty=tformat: --name-only $1
        fi
      }; f";

      # repo main/master disambiguation
      main = "!f() { git symbolic-ref refs/remotes/origin/HEAD --short | cut -d/ -f2; }; f";

      # fast ops on main/master
      pm = "!f() { test $(git rev-parse --abbrev-ref HEAD) != $(git main) && git fetch origin $(git main):$(git main) || git p; }; f"; # pull main
      bd = "!f() {
        git pm || return;
        for branch in $(git for-each-ref --format '%(refname:short)' refs/heads | grep -vE '^main$|^master$')
        do
          echo;
          if git log --cherry --pretty=format:'%m\ %C(yellow)%h\ %C(green)%ad%Cred%d\ %Creset%s%Cblue\ [%an]' --date=relative $(git main)...$branch | grep --silent -E '^>';
          then
            echo \"$branch is unmerged:\";
            git log --cherry --pretty=format:'%m\ %C(yellow)%h\ %C(green)%ad%Cred%d\ %Creset%s%Cblue\ [%an]' --date=relative $(git main)...$branch;
          else
            git branch -D $branch;
          fi
        done
      }; f";
      rbmi = "!f() { git pm && git rb -i $(git main); }; f"; # rebase interactively on main
      rbm = "!f() { git pm && git rb $(git main); }; f"; # rebase on main

      # update PR with unstaged
      rekt = "!f() { git a -u; git amend; git puf; }; f"; # add updates to amend commit and force push
    };
    ignores = [
      "*~"
      "*.swp"
    ];
    extraConfig = {
      branch.sort = "-committerdate";
      commit.gpgsign = true;
      core = {
        excludesfile = "~/.gitignore";
        attributesfile = "~/.gitattributes";
      };
      diff.algorithm = "histogram";
      gpg.format = "ssh";
      init.defaultBranch = "main";
      log.date = "local";
      pull.rebase = true;
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      rebase = {
        autosquash = true;
        autostash = true;
        updateRefs = true;
      };
      merge.autostash = true;
      rerere.enabled = true;
      tag.sort = "version:refname";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      user.signingkey = "~/.ssh/id_ed25519";
      "merge \"mergiraf\"" = {
        name = "mergiraf";
        driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P";
      };
    };
  };
}
