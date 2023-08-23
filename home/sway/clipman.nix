{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    wofi
  ];

  services.clipman = {
    enable = true;
    systemdTarget = "graphical-session.target";
  };
}
