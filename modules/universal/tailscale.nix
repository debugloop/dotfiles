_: {
  flake.modules.nixos.tailscale = {
    pkgs,
    config,
    inputs,
    ...
  }: {
    # Pin to 1.96.4: versions 1.98.x have a bug where Config.Clone drops
    # nil-valued Routes, breaking MagicDNS after any link change event.
    # https://github.com/tailscale/tailscale/issues/19730
    # Remove once a fixed release (> 1.98.1) is available in nixpkgs.
    services.tailscale.package = pkgs.tailscale.overrideAttrs (_old: rec {
      version = "1.96.4";
      src = pkgs.fetchFromGitHub {
        owner = "tailscale";
        repo = "tailscale";
        tag = "v${version}";
        hash = "sha256-VnAEfY8W+2QPnQLvVFJA7/XyvSnppSdRvgAOgpmRFGM=";
      };
      vendorHash = "sha256-rhuWEEN+CtumVxOw6Dy/IRxWIrZ2x6RJb6ULYwXCQc4=";
    });

    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscaleAuthkey.path;
      authKeyParameters = {
        preauthorized = true;
        ephemeral = false;
      };
      extraUpFlags = ["--advertise-tags=tag:nix"];
      openFirewall = true;
      useRoutingFeatures = "client";
    };

    environment.systemPackages = [config.services.tailscale.package];

    networking.firewall = {
      trustedInterfaces = [
        "tailscale0"
      ];
    };

    age.secrets = {
      tailscaleAuthkey.file = inputs.self + "/secrets/tailscale.age";
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/tailscale"
      ];
    };
  };
}
