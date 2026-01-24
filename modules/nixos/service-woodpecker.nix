{
  config,
  lib,
  pkgs,
  ...
}: {
  services = {
    woodpecker-server = {
      enable = true;
      environmentFile = "${config.age.secrets.woodpecker.path}";
      environment = {
        WOODPECKER_ADMIN = "debugloop";
        WOODPECKER_HOST = "https://ci.danieln.de";

        WOODPECKER_GITEA = "true";
        WOODPECKER_GITEA_URL = "https://codeberg.org";

        WOODPECKER_SERVER_ADDR = "localhost:8082";
      };
    };
    woodpecker-agents.agents.local = {
      enable = true;
      environmentFile = ["${config.age.secrets.woodpecker.path}"];
      environment = {
        WOODPECKER_SERVER = "localhost:9000";
        WOODPECKER_BACKEND = "local";
        WOODPECKER_HEALTHCHECK_ADDR = "localhost:3004";
      };
      path = with pkgs; [
        git
        git-lfs
        bash
        curl
        jq
        nix
      ];
    };
  };

  # NOTE: Required by the .#update script specifically for inline sed replace.
  systemd.services.woodpecker-agent-local.serviceConfig.SystemCallFilter = ["@chown"];

  age.secrets.woodpecker.file = ../../secrets/woodpecker.age;

  services.caddy.virtualHosts."ci.danieln.de".extraConfig = ''
    reverse_proxy localhost:8082
  '';
}
