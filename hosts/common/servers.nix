{ inputs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.danieln = import ../../home/headless.nix;
    extraSpecialArgs = {
      inherit inputs;
    };
  };

  services = {
    prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
      };
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

  };
}
