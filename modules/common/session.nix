{...}: {
  flake.homeModules.common_session = {pkgs, ...}: {
    home = {
      sessionVariables = {
        HIGHLIGHT_STYLE = "base16/grayscale-dark";
        PAGER = "less -R --use-color -Dd+r -Du+b";
      };
      packages = [pkgs.highlight];
    };

    programs = {
      dircolors.enable = true;
      less.enable = true;
    };
  };
}
