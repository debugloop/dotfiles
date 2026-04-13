_: {
  flake.homeModules.clipman = {pkgs, ...}: {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    services.clipman = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };
  };
}
