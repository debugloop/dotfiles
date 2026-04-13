_: {
  flake.nixosModules.users = {
    config,
    pkgs,
    ...
  }: {
    users = {
      mutableUsers = false;
      users.danieln = {
        isNormalUser = true;
        extraGroups = ["wheel" "video" "docker" "libvirtd" "dialout" "scanner" "lp"];
        shell = pkgs.fish;
        hashedPasswordFile = config.age.secrets.password.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJvfqr6PpG4BHmUHcj7LzfYhPjoxGeLGxNGF6FAXauX danieln@lusus"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXLvABfBx2ThhJ/nUYaLFu2QyLYomOn4BrKUnbwGeWk danieln@simmons"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGO/7gSRKMzTR1bSjpirDN/AIG4Mw55GyiLck9ppvzj2 JuiceSSH"
        ];
      };

      users.root = {
        # NOTE: This is of course not smart, but should not matter as it is only
        # usable locally. Having this hash outside agenix keeps a backdoor for
        # myself open in case something goes wrong with agenix, impermanence, or
        # anything else.
        initialHashedPassword = "$y$j9T$1DGnFy3m6PTbQoYB5kICV1$7gzz.2guf2Lj1wy4uo.YR0r1TfhI6/OTvjSi7.Tcm56";
      };
    };

    security.sudo.extraConfig = ''
      Defaults passprompt="[sudo] password for %p: "
    '';
  };
}
