{lib, ...}: {
  options.flake.sshForwardAgentHosts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Hostnames for which SSH agent forwarding should be enabled.";
  };
}
