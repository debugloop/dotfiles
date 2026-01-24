{config, ...}: {
  services.factorio = {
    enable = false;
    openFirewall = true;
    loadLatestSave = true;
    requireUserVerification = false;
    extraSettingsFile = "${config.age.secrets.factorio.path}";
  };

  age.secrets.factorio.file = ../../secrets/factorio.age;
}
