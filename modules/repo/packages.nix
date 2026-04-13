{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages = {
      host-keygen = import (inputs.self + "/packages/host-keygen.nix") {inherit pkgs;};
      nvim = import (inputs.self + "/packages/nvim.nix") {inherit pkgs;};
      install = import (inputs.self + "/packages/install.nix") {inherit pkgs inputs;};
    };
  };
}
