{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages = {
      host-keygen = import ../../packages/host-keygen.nix {inherit pkgs;};
      nvim = import ../../packages/nvim.nix {inherit pkgs;};
      install = import ../../packages/install.nix {inherit pkgs inputs;};
    };
  };
}
