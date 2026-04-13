_: {
  flake.homeModules.base = {pkgs, ...}: {
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
