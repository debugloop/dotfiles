{ ... }: {
  flake.modules.nixos.common_openssh = { ... }: {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
  };
}
