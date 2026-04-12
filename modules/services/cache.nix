{...}: {
  flake.nixosModules.service_cache = {...}: {
    nix.sshServe = {
      enable = true;
      keys = [
        (builtins.readFile ../../keys/hosts/simmons.pub)
        (builtins.readFile ../../keys/hosts/lusus.pub)
      ];
    };
  };
}
