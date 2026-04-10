{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModule
  ];

  age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=1G" "mode=755"];
  };

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
    users.danieln = {
      directories = [
        "code"
        "documents"
        "downloads"
        "pictures"
        ".backup"
        ".cache"
        ".undo"
        {
          directory = ".gxctl";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".aws";
          mode = "0700";
        }
        {
          directory = ".config/rbw";
          mode = "0700";
        }
        ".claude"
        ".local/share/direnv"
        ".local/share/nix"
        ".local/share/fish"
        ".local/share/atuin"
        ".local/share/zoxide"
        "go"
        ".local/share/posting"
      ];
      files = [".netrc" ".claude.json" ".kube/config"];
    };
  };
}
