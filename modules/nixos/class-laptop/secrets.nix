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
    hetzner_storagebox_tfstate_user = {
      file = ../../../secrets/hetzner_storagebox_tfstate_user.age;
      owner = "danieln";
    };
    hetzner_storagebox_tfstate_password = {
      file = ../../../secrets/hetzner_storagebox_tfstate_password.age;
      owner = "danieln";
    };
  };
}
