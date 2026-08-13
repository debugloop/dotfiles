_: {
  flake.modules.homeManager.git = {config, ...}: {
    home.file = {
      ".gitignore".text = ''
        .session.nvim
      '';
    };

    programs = {
      git = {
        enable = true;
        signing.format = null;
        settings = {
          user = {
            name = "Daniel Nägele";
            email = "git@danieln.de";
          };
          advice = {
            skippedCherryPicks = false;
          };
          branch.sort = "-committerdate";
          commit = {
            gpgsign = true;
            verbose = true;
          };
          core = {
            excludesfile = "~/.gitignore";
          };
          diff = {
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
            renames = true;
          };
          fetch = {
            prune = true;
            pruneTags = true;
            all = true;
          };
          gpg.format = "ssh";
          help.autocorrect = "prompt";
          init.defaultBranch = "main";
          log.date = "local";
          merge = {
            autostash = true;
            conflictStyle = "zdiff3";
          };
          pull.rebase = true;
          push = {
            default = "simple";
            autoSetupRemote = true;
            followTags = true;
          };
          rebase = {
            autosquash = true;
            autostash = true;
            stat = true;
            updateRefs = true;
          };
          remote.origin.followRemoteHEAD = "create";
          rerere = {
            enabled = true;
            autoupdate = true;
          };
          tag.sort = "version:refname";
          url."ssh://git@github.com/".insteadOf = "https://github.com/";
          user.signingkey = "~/.ssh/id_ed25519";

          alias = {
            # shorthands for daily stuff
            a = "add";
            amend = "commit --amend --no-edit";
            b = "branch --color='always' --sort=-authordate --format='%(color:yellow)%(refname:short)\ %(color:green)%(committerdate:relative)\ %(color:blue)%(authorname)'";
            bv = "branch --color='always' --sort=-authordate --format='%(color:yellow)%(refname:short)\ %(color:green)%(committerdate:relative)\ %(color:blue)%(authorname)\ %(color:reset)%(contents:subject)'";
            ci = "commit";
            ch = "cherry -v";
            d = "diff";
            ds = "-c delta.side-by-side=true d";
            dc = "d -- :^vendor :^go.mod :^go.sum";
            dsc = "-c delta.side-by-side=true dc";
            fixup = "commit --fixup";
            fi = "commit --fixup";
            # base log
            log-pretty = "log --pretty=format:'%C(yellow)%h\ %C(green)%ad%Cred%d\ %C(reset)%s%C(blue)\ [%an]' --date=relative";
            log-cherry = "log --cherry-mark --pretty=format:'%C(yellow)%h\ %C(cyan)%m\ %C(green)%ad%Cred%d\ %C(reset)%s%C(blue)\ [%an]' --date=relative";
            # aliases for use
            l = "!f() {
        if [ $# -eq 0 ]; then
          if [ \"$(git main)\" = \"$(git rev-parse --abbrev-ref HEAD)\" ]; then
            set - -32
          else
            set -- $(git main)..
          fi
        fi
        if [[ \"$@\" == *\"...\"* ]]; then
          git log-cherry \"$@\"
        else
          git log-pretty \"$@\"
        fi
      }; f";
            lg = "!f() {
        if [ $# -eq 0 ]; then
          if [ \"$(git main)\" = \"$(git rev-parse --abbrev-ref HEAD)\" ]; then
            set - -16
          else
            set -- $(git main)..
          fi
        fi
        if [[ \"$@\" == *\"...\"* ]]; then
          git log-cherry --graph --boundary \"$@\"
        else
          git log-pretty --graph --boundary \"$@\"
        fi
      }; f";
            new = "log-pretty @{u}...";
            p = "pull --prune --all --autostash";
            pm = "!git fetch origin $(git main):$(git main) 2>/dev/null";
            # local branches that make up the current stack (base->top): every
            # local branch whose tip is reachable from HEAD but not from main.
            # One clean branch name per line, so `puf` can pipe it into push.
            stack = "!git for-each-ref --format='%(refname:short)' refs/heads/ --merged HEAD --no-merged $(git main) --sort=committerdate";
            puf = "!git stack | xargs git push --set-upstream --force-with-lease --force-if-includes origin";
            rb = "!f() {
        if [ $# -eq 0 ]; then
          git fetch origin $(git main):$(git main)
          set -- $(git main);
        fi && git rebase \"$@\";
      }; f";
            rbi = "!f() {
        if [ $# -eq 0 ]; then
          set -- $(git main);
        fi;
        git rebase --interactive --keep-base \"$@\";
      }; f";
            rba = "rebase --abort";
            rbc = "rebase --continue";
            ours = "restore --ours";
            theirs = "restore --theirs";
            s = "status --short";
            sh = "show --stat";
            sw = "switch";

            # repo path
            root = "rev-parse --show-toplevel"; # print root
            cd = "!cd $(git rev-parse --show-toplevel)"; # change to root
            exec = "!exec "; # make from wherever

            # files from index or from commits
            f = "!f() {
        if [ $# -eq 0 ]; then
          git ls-files --modified --others --exclude-standard | grep -Ev '^(vendor/|go.(mod|sum)$)'
        else
          git diff --name-only $@ | grep -Ev '^(vendor/|go.(mod|sum)$)'
        fi
      }; f";

            # repo main/master disambiguation. Ask for the ref itself instead of
            # asking whether a remote exists: remote.origin.* in the global
            # config makes `git remote` list origin even in a repo that has
            # none, and symbolic-ref then fails and yields an empty name. Cut
            # from the second field on, so origin/release/1.x keeps its slashes.
            main = "!git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | cut -d/ -f2- | grep . || echo main";

            # update PR with unstaged
            rekt = "!f() { git a -u; git amend; git puf; }; f"; # add updates to amend commit and force push
          };
        };
        ignores = [
          "*~"
          "*.swp"
        ];
      };
      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          file-style = "omit";
          hunk-header-decoration-style = "blue ul box";
          hunk-header-style = "file line-number syntax";
          navigate = "true";
          tabs = "4";
          syntax-theme = "ansi";
          map-styles = "bold purple => syntax dim black, bold cyan => syntax #${config.colors.black}";
        };
      };
    };
  };
}
