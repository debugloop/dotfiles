_: {
  flake.modules.nixos.openssh = {config, ...}: {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    environment.persistence."/nix/persist".users.${config.mainUser}.directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
