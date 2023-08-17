{ config, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      format = "$all";
      right_format = "$battery";

      # left hand side
      username = {
        format = "[$user]($style)";
        style_user = "bright-green";
        show_always = true;
      };

      hostname = {
        format = "@[$hostname]($style)";
        style = "none";
        ssh_only = true;
      };

      directory = {
        format = " [$path]($style)[$read_only]($read_only_style) ";
        repo_root_format = " [$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        truncate_to_repo = false;
        style = "green";
        before_repo_root_style = "green";
        repo_root_style = "bold green";
        read_only = "✖";
      };

      git_branch = {
        format = "\\([$symbol$branch(:$remote_branch)]($style)";
        symbol = "";
      };

      git_commit = {
        format = "\\([$hash$tag]($style)";
        style = "purple";
        tag_disabled = false;
      };

      git_status = {
        format = "[$conflicted$deleted$renamed](red)[$modified](blue)[$staged](yellow)[$untracked$stashed](bright-black)[$ahead_behind](bold)\\) ";
        style = "bright-black";
        ahead = " ↑$count";
        behind = " ↓$count";
        diverged = " ↑$ahead_count↓$behind_count";
        conflicted = "$count";
        deleted = " ✖$count";
        modified = " ✚$count";
        renamed = " »$count";
        staged = " ●$count";
        stashed = " ✱$count";
        untracked = " …$count";
      };

      status = {
        disabled = false;
        pipestatus = true;
        format = "[$status $common_meaning$signal_name]($style)";
      };

      aws = {
        disabled = true;
      };

      # language runtimes
      golang = {
        format = "[$symbol($version )]($style)";
        symbol = " ";
      };

      lua = {
        format = "[$symbol($version )]($style)";
        symbol = " ";
      };

      nix_shell = {
        format = "[$symbol$state( \($name\))]($style)";
        symbol = " ";
      };

      python = {
        format = "[$symbol$pyenv_prefix($version )(\($virtualenv\) )]($style)";
        symbol = " ";
      };

      docker_context = {
        disabled = true;
      };

      custom.persistent = {
        when = ''not persistent'';
        format = "[󱙄](bold) ";
      };
    };
  };
}
