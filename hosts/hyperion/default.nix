{ ... }:

{
  imports =
    [
      ./boot.nix
      ../services/caddy.nix
      ../services/grafana.nix
      ../services/grocy.nix
      ../services/matrix.nix
      ../services/miniflux.nix
      ../services/prometheus.nix
    ];
}
