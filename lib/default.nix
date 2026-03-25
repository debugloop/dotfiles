_: {
  mkHetznerEnv = statePrefix: ''
    export TF_VAR_hcloud_token="$(cat /run/agenix/hetzner_token)"
    export TF_VAR_storage_box_id="$(cat /run/agenix/hetzner_storagebox_id)"
    export TF_HTTP_USERNAME="$(cat /run/agenix/hetzner_storagebox_tfstate_user)"
    export TF_HTTP_ADDRESS="https://$(cat /run/agenix/hetzner_storagebox_tfstate_user).your-storagebox.de/${statePrefix}-terraform.tfstate"
    export TF_HTTP_PASSWORD="$(cat /run/agenix/hetzner_storagebox_tfstate_password)"
    export TF_HTTP_UPDATE_METHOD="PUT"
    export TF_HTTP_LOCK_METHOD="PUT"
    export TF_HTTP_UNLOCK_METHOD="DELETE"
  '';
}
