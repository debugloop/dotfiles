_: {
  flake.modules.homeManager.extras = {pkgs, ...}: {
    home.packages = with pkgs; [
      doggo
      dool
      entr
      gping
      jrnl
      miniserve
      renameutils
      tailspin
      xan
    ];
  };
}
