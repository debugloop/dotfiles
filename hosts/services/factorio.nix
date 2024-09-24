{config, ...}: {
  services.factorio = {
    enable = true;
    openFirewall = true;
    loadLatestSave = true;
    requireUserVerification = false;
    extraSettingsFile = "${config.age.secrets.factorio.path}";
  };

  age.secrets.factorio.file = ../../secrets/factorio.age;

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/private";
        mode = "0700";
      }
    ];
  };
}
