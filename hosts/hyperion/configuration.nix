{flake, ...}: {
  imports = [
    ./boot.nix
    flake.nixosModules.common
    flake.nixosModules.servers
    flake.nixosModules.service-caddy
    flake.nixosModules.service-factorio
    flake.nixosModules.service-grafana
    flake.nixosModules.service-grocy
    flake.nixosModules.service-matrix
    flake.nixosModules.service-miniflux
    flake.nixosModules.service-prometheus
    flake.nixosModules.service-restic-rest
  ];
}
