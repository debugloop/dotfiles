_: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      gavin-bc
      dmidecode
      lsof
      moreutils
      unzip
      watch
      zip
    ];
  };
}
