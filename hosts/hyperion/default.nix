{ ... }:

{
  imports =
    [
      ./boot.nix
      ../services/caddy.nix
      ../services/grafana.nix
      ../services/grocy.nix
      ../services/prometheus.nix
    ];
}
