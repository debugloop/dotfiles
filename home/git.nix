{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      git
    ];
    file.".gitignore".text = ''
      .session.nvim
    '';
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
      l = "log --pretty=format:'%C(yellow)%h\ %C(green)%ad%Cred%d\ %Creset%s%Cblue\ [%an]' --date=relative -32";
      lg = "l --graph --boundary --cherry-mark";
      lp = "-c delta.side-by-side=true log --pretty=format:'%C(yellow)commit %h\ %C(green)%ad%Cred%d\ %Creset%s%Cblue\ [%an]' --date=relative -16 -p -- :^vendor :^go.mod :^go.sum"; # include "commit " for delta `n` navigation
      new = "l @{u}..";
      p = "pull --prune --all --autostash";
      puf = "push --force-with-lease --force-if-includes";
      rb = "rebase --autostash --autosquash";
      rba = "rebase --abort";
      rbc = "rebase --continue";
      s = "status --short";
      sw = "switch";

      # repo path
      root = "rev-parse --show-toplevel"; # print root
      cr = "!f() {cd $(git rev-parse --show-toplevel)}"; # change to root
      exec = "!exec "; # make from wherever

      # files from commits
      f = "show -m --pretty=tformat: --name-only";

      # fancy branch switch
      go = "!f() { git branch | fzf | head -n1 | cut -c 3- | xargs git switch;}; f";

      # repo main/master disambiguation
      main = "symbolic-ref refs/remotes/origin/HEAD --short";
      rbmi = "!f() { git rb -i $(git main); }; f";
      rbm = "!f() { git rb $(git main); }; f";
      main-alias = "!git symbolic-ref refs/heads/main refs/heads/master && git symbolic-ref refs/remotes/origin/main refs/remotes/origin/master";

      # PR visualization: `gh pr checkout XXX`
      dpr = "!f() { git ds $(git main)...; }; f";
      lpr = "!f() { git lg $(git main)...; }; f";

      rekt = "!f() { git a -u; git amend; git puf; }; f";
    };
    ignores = [
      "*~"
      "*.swp"
    ];
    extraConfig = {
      commit.gpgsign = true;
      core.excludesfile = "~/.gitignore";
      gpg.format = "ssh";
      pull.rebase = true;
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      rebase.autosquash = true;
      rerere.enabled = true;
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      user.signingkey = "~/.ssh/id_ed25519";
    };
  };
}
