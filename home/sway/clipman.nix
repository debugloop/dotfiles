{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    wofi
  ];

  services.clipman = {
    enable = true;
    systemdTarget = "sway-session.target";
  };
}
