{...}: {
  services.restic.server = {
    enable = true;
    prometheus = true;
    htpasswd-file = "/var/lib/restic/htpasswd";
    extraFlags = [
      "--no-auth"
    ];
  };

  # no firewall rule means only accessible on trusted interfaces, i.e. lo and tailscale

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/restic"
    ];
  };
}
