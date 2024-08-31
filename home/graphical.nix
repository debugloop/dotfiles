{pkgs, ...}: {
  imports = [
    ./wayland
  ];

  manual = {
    html.enable = true;
  };

  home = {
    packages = with pkgs; [
      # cli working with graphical stuff
      ghostscript_headless
      graphviz
      imagemagick
      pdftk
      # not precisely graphical, but require physical access
      dfu-util
      gcc-arm-embedded
      qmk
    ];
  };
}
