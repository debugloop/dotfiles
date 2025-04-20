{inputs, ...}: {
  imports = [
    ./boot.nix
    ../services/caddy.nix
    ../services/factorio.nix
    ../services/grafana.nix
    ../services/grocy.nix
    ../services/matrix.nix
    ../services/miniflux.nix
    ../services/prometheus.nix
    ../services/restic-rest.nix
    inputs.wunschkonzert-install.include
  ];
}
