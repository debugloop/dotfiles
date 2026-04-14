_: {
  flake.modules.nixos.kubernetes = {config, ...}: {
    environment.persistence."/nix/persist".users.${config.mainUser} = {
      files = [".kube/config"];
    };
  };

  flake.modules.homeManager.kubernetes = {pkgs, ...}: {
    home = {
      sessionVariables = {
        KUBECTL_EXTERNAL_DIFF = "${pkgs.dyff}/bin/dyff between --omit-header --set-exit-code";
      };
      packages = with pkgs; [
        dyff
        k6
        kontemplate
        kubeconform
        kubectl
        kustomize
      ];
    };
  };
}
