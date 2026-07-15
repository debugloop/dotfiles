{inputs, ...}: {
  flake.modules.nixos.substituters = {config, ...}: {
    age.secrets.nix-ci-netrc = {
      file = inputs.self + "/secrets/nix-ci-netrc.age";
      owner = config.mainUser;
      mode = "0400";
    };

    nix.settings = {
      extra-substituters = ["https://cache.nix-ci.com"];
      extra-trusted-public-keys = ["nix-ci:g3xV5BDTLtIBZr/A00IU1x0EtKKlb7YLgBN2SgYgM6A="];
      netrc-file = config.age.secrets.nix-ci-netrc.path;
    };
  };
}
