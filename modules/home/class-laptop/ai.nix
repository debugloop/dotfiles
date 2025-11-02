{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      awsume
      claude-code
      copilot-language-server
      github-copilot-cli
      amp-cli
    ];
  };
}
