{...}: {
  virtualisation = {
    docker = {
      enable = false; # rootful docker disabled
      daemon.settings = {
        rootless = {
          enable = true;
          setSocketVariable = true;
          bip = "10.200.0.1/24";
          default-address-pools = [
            {
              base = "10.201.0.0/16";
              size = 24;
            }
            {
              base = "10.202.0.0/16";
              size = 24;
            }
          ];
        };
      };
    };
  };
}
