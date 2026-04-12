_: {
  flake.nixosModules.laptop_fonts = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      fira
      fira-code
      fira-code-symbols
      fira-go
      fira-math
      iosevka
      # nerd-fonts.fira-code
      # nerd-fonts.fira-mono
      # nerd-fonts.noto
      # nerd-fonts.iosevka
      nerd-fonts.symbols-only
      # noto-fonts
      # noto-fonts-monochrome-emoji
      # noto-fonts-lgc-plus
      roboto
      roboto-mono
    ];
  };
}
