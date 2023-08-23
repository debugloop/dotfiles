{ pkgs, ... }:

{
  time = {
    timeZone = "Europe/Berlin";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = { LC_TIME = "en_GB.UTF-8"; };
    supportedLocales = [ "en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" ];
  };

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "${pkgs.ddcutil}/bin/ddcutil";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
