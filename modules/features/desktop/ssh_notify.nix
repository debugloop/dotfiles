_: {
  flake.modules.homeManager.ssh_notify = {pkgs, ...}: {
    programs.ssh.extraConfig = ''
      PermitLocalCommand yes
      LocalCommand ${pkgs.libnotify}/bin/notify-send --category=ssh "%r@%h" "Connected to %h."
    '';
  };
}
