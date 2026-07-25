_: {
  flake.modules.nixos.vm = {
    config,
    lib,
    ...
  }: {
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
      users.users.${config.mainUser}.hashedPasswordFile = lib.mkForce null;
      users.users.${config.mainUser}.initialHashedPassword = "";
    };
  };
}
