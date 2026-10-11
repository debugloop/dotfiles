_: {
  flake.modules.nixos.tailscale_personal = {
    config,
    inputs,
    ...
  }: {
    imports = [inputs.self.modules.nixos.tailscale];

    services.tailscale = {
      authKeyFile = config.age.secrets.tailscale_auth_key.path;
      authKeyParameters = {
        preauthorized = true;
        ephemeral = false;
      };
      extraUpFlags = ["--advertise-tags=tag:nix"];
    };

    networking.firewall.trustedInterfaces = ["tailscale0"];

    age.secrets.tailscale_auth_key.rekeyFile = inputs.self + "/secrets/tailscale_auth_key.age";
  };
}
