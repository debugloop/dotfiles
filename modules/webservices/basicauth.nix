_: {
  flake.modules.nixos.basicauth = {lib, ...}: {
    options.webservices.basicauth = lib.mkOption {
      type = lib.types.str;
      default = "danieln $2a$14$BHCi0dM1slv2JypVYffCZ.LAbPH8x3037LwVlRaxySIppSPR1Ixlm";
      description = "Shared Caddy basicauth bcrypt hash line.";
    };
  };
}
