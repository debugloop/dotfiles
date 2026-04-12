{...}: {
  flake.nixosModules.common_vm = {lib, ...}: {
    virtualisation.vmVariant = {
      # better performance and no qcow, it's not persisted anyhow
      virtualisation = {
        memorySize = 2048;
        cores = 2;
        diskImage = null;
        qemu.options = [];
      };
      environment.persistence = lib.mkForce {};
      # empty password for myself
      age = lib.mkForce {};
      users.users.danieln.hashedPasswordFile = lib.mkForce null;
      users.users.danieln.initialHashedPassword = "";
    };
  };
}
