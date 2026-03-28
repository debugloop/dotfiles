{...}: {
  age.secrets = {
    hetzner_token = {
      file = ../../../secrets/hetzner_token.age;
      owner = "danieln";
    };
    hetzner_storagebox_id = {
      file = ../../../secrets/hetzner_storagebox_id.age;
      owner = "danieln";
    };
    hetzner_tfstate_passphrase = {
      file = ../../../secrets/hetzner_tfstate_passphrase.age;
      owner = "danieln";
    };
  };
}
