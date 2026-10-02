_: {
  flake.modules.nixos.tailscale_personal = {
    config,
    inputs,
    ...
  }: {
    imports = [inputs.self.modules.nixos.tailscale];

    services.tailscale = {
      authKeyFile = config.age.secrets.tailscaleAuthkey.path;
      authKeyParameters = {
        preauthorized = true;
        ephemeral = false;
      };
      extraUpFlags = ["--advertise-tags=tag:nix"];
    };

    networking.firewall.trustedInterfaces = ["tailscale0"];

    age.secrets.tailscaleAuthkey.file = inputs.self + "/secrets/tailscale.age";
  };
}
