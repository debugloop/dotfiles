_: {
  flake.modules.nixos.sudo_u2f = {
    config,
    inputs,
    pkgs,
    ...
  }: {
    security.pam = {
      services.sudo = {
        u2f = {
          enable = true;
          control = "sufficient";
        };
        rules.auth.u2f.order = config.security.pam.services.sudo.rules.auth.unix.order + 10;
      };
      u2f.settings = {
        authfile = "/etc/security/sudo-u2f";
        origin = "pam://sudo";
        appid = "pam://sudo";
        cue = true;
        userpresence = 1;
        pinverification = 0;
        userverification = 0;
      };
    };

    environment.systemPackages = [pkgs.pam_u2f];
    environment.etc."security/sudo-u2f".source = inputs.self + "/keys/pam-u2f";
  };
}
