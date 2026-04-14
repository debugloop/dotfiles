_: {
  flake.modules.nixos.impermanence = {
    config,
    inputs,
    ...
  }: {
    imports = [
      inputs.impermanence.nixosModule
    ];

    age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];

    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=1G" "mode=755"];
    };

    programs.fuse.userAllowOther = true;

    systemd.services.pre-shutdown.enable = false;

    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        "/etc/nixos"
        "/var/lib/nixos"
        "/var/log"
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
      users.${config.mainUser} = {
        directories = [
          "code"
          "documents"
          "downloads"
          "pictures"
          ".cache"
        ];
      };
    };
  };
}
