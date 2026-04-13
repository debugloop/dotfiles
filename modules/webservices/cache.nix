_: {
  flake.modules.nixos.cache = {inputs, ...}: {
    nix.sshServe = {
      enable = true;
      keys = [
        (builtins.readFile (inputs.self + "/keys/hosts/simmons.pub"))
        (builtins.readFile (inputs.self + "/keys/hosts/lusus.pub"))
      ];
    };
  };
}
