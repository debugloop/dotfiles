{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pamixer
  ];

  services.avizo = {
    enable = true;
    settings = {
      default = {
        background = "rgba(160, 160, 160, 0.6)";
        border-color = "rgba(90, 90, 90, 0.6)";
        bar-fg-color = "rgba(0, 0, 0, 0.7)";
        time = 3.0;
      };
    };
  };
}
