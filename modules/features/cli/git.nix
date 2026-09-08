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
            # plain absorb refuses commits that other branches point at, which is
            # every commit below the top of a stack, so always aim at the trunk.
            ab = "!git absorb --base $(git base)";
            # base log
            log-pretty = "log --pretty=format:'%C(yellow)%h\ %C(green)%ad%Cred%d\ %C(reset)%s%C(blue)\ [%an]' --date=relative";
            log-cherry = "log --cherry-mark --pretty=format:'%C(yellow)%h\ %C(cyan)%m\ %C(green)%ad%Cred%d\ %C(reset)%s%C(blue)\ [%an]' --date=relative";
            # aliases for use
            l = "!f() {
        if [ $# -eq 0 ]; then
          if [ \"$(git main)\" = \"$(git rev-parse --abbrev-ref HEAD)\" ]; then
            set - -32
          else
            set -- $(git base)..
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
            set -- $(git base)..
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
            # local branches that make up the current stack, bottom to top:
            # every local branch whose tip sits on a commit in main..HEAD,
            # emitted in the order the commits appear. One clean branch name
            # per line, so `puf` can pipe it into push. The order is a contract
            # for `pufl`, which derives PR base branches from it, so walk the
            # commits topologically instead of sorting tips by date.
            stack = "!f() {
        base=$(git base);
        {
          git for-each-ref --format='ref %(objectname) %(refname:short)' refs/heads/;
          git rev-list --reverse --topo-order \"$base..HEAD\" | sed 's/^/rev /';
        } | awk '
          $1==\"ref\" { tips[$2] = ($2 in tips ? tips[$2] \" \" : \"\") $3 }
          $1==\"rev\" && ($2 in tips) {
            n = split(tips[$2], names, \" \");
            for (i = 1; i <= n; i++) print names[i];
          }
        ';
      }; f";
            # push every branch of the stack. --force-if-includes stays on: a
            # rejection means something rewrote a branch behind my back, and
            # stack-pull below is the answer to that, not a bigger hammer.
            puf = "!git stack | xargs -r git push --set-upstream --force-with-lease --force-if-includes origin";
            # create the stack on GitHub: gh opens a PR per branch, chains their
            # bases, and links them. It pushes branches that the remote lacks, but
            # only fast forward, so run `puf` first when a rewrite is unpushed.
            # Only for creating or extending a stack: link refuses to update one
            # that already has a merged PR. Never bundled with `puf`, so nothing
            # named link can force push behind my back.
            stack-link = "!gh stack link $(git stack)";
            # the other direction: adopt whatever the remote holds for every branch
            # of the stack. GitHub restacks the branches
            # itself when the bottom PR merges, and taking that is less work than
            # rebasing against it. Loops instead of piping into fetch, because fetch
            # refuses to write the checked out branch. A branch whose commits are
            # all upstream by patch id is a restack and gets reset; anything else is
            # real local work and is left alone, because --keep only guards the
            # worktree, not commits. Leaves the local trunk branch alone: nothing
            # here computes against it, `base` reads the remote tracking ref.
            stack-pull = "!f() {
        git fetch -pq;
        for b in $(git stack); do
          git switch -q $b || continue;
          if git cherry @{u} | grep -q '^+'; then
            echo \"$b: holds commits that are not upstream, skipped\";
          else
            git reset -q --keep @{u};
          fi;
        done;
      }; f";
            rb = "!f() {
        if [ $# -eq 0 ]; then
          git fetch origin $(git main):$(git main)
          set -- $(git main);
        fi && git rebase \"$@\";
      }; f";
            rbi = "!f() {
        if [ $# -eq 0 ]; then
          set -- $(git base);
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
            # the trunk ref my work is based on, as opposed to `main`, which is the
            # trunk branch *name* for refspecs and switching. Prefer the remote
            # tracking ref: the local branch lags whenever the remote moves, and a
            # lagging boundary lets absorb and rebase reach commits that already
            # landed upstream. Falls back to the local branch in a repo with no
            # remote.
            base = "!f() { m=$(git main); git rev-parse -q --verify origin/$m >/dev/null && echo origin/$m || echo $m; }; f";

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
