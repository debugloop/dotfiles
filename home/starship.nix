{ lib, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      format = lib.strings.concatStrings [
        "$sudo$username$hostname" # usually hidden
        "$directory$custom"
        "$git_branch$git_commit$git_state$git_status"
        "$cmd_duration"
        "$line_break"
        "$jobs$status$character"
      ];
      right_format = "$memory_usage$battery";

      cmd_duration = {
        show_notifications = true;
      };

      custom.persistent = {
        when = ''not persistent'';
        format = "[󱙄](bold) ";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        truncate_to_repo = false;
        style = "green";
        before_repo_root_style = "green";
        repo_root_style = "bold green";
        read_only = "✖";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style)";
        symbol = " ";
      };

      git_commit = {
        format = "[ $hash$tag]($style)";
        style = "purple";
        tag_disabled = false;
        tag_symbol = "  ";
      };

      git_state = {
        format = " [$state $progress_current/$progress_total]($style) ";
        rebase = " REBASE";
      };

      git_status = {
        format = "[$conflicted](red)[$deleted$renamed$modified](blue)[$staged](yellow)[$untracked$stashed](bright-black)[$ahead_behind](bold) ";
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

      hostname = {
        format = "[$hostname]($style) ";
        style = "none";
        ssh_only = true;
      };

      memory_usage = {
        disabled = false;
        format = "[$symbol$ram]($style) ";
        style = "bold red";
        symbol = "";
      };

      status = {
        disabled = false;
        pipestatus = true;
        format = "[$status $common_meaning$signal_name]($style)";
      };

      sudo = {
        style = "green";
        format = "[$symbol]($style) ";
        symbol = "";
        disabled = false;
      };

      username = {
        format = "[$user]($style) ";
        style_user = "bright-green";
        show_always = false;
      };
    };
  };
}
