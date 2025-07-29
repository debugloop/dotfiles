{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModule
  ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=1G" "mode=755"];
  };

  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos" # our config
      "/etc/NetworkManager/system-connections" # network manager connections
      "/var/lib/bluetooth" # blueman connections
      "/var/lib/nixos" # uid and gid mappings
      "/var/log" # logs
      "/var/lib/docker" # docker rootful
    ];
    files = [
      "/etc/machine-id" # important, e.g. for journald
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users.danieln = {
      directories = [
        # personal dirs
        "code"
        "documents"
        "downloads"
        "pictures"
        # messy applications
        ".mozilla"
        ".thunderbird"
        ".config/google-chrome"
        ".config/Slack"
        ".config/Postman"
        ".config/qView"
        ".local/share/docker"
        ".ts3client"
        ".local/share/Steam"
        # others
        ".backup" # nvim backups
        ".cache" # cache between boots, save that memory
        "go" # go libs
        ".undo" # nvim undo
        ".local/state/wireplumber" # volume settings
        # history for shells
        ".local/share/direnv"
        ".local/share/zoxide"
        ".local/share/fish"
        ".local/share/atuin"
        ".local/share/nix"
        ".local/share/posting"
        # secrets
        {
          directory = ".aws";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".gxctl";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        {
          directory = ".config/rbw";
          mode = "0700";
        }
      ];
      files = [
        # spotify login cookie
        ".config/spotify/prefs"
        # spotify user settings
        ".config/spotify/Users/analogbyte-user/prefs"
        # kubectl settings
        ".kube/config"
        # other
        ".netrc"
      ];
    };
  };
}
