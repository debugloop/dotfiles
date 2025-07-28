{
  pname,
  pkgs,
}: let
  formatter = pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = [
      pkgs.alejandra
    ];

    text = ''
      if [ $# -eq 0 ]; then
        set -- "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
      fi

      alejandra "$@"
    '';

    meta = {
      description = "format your project";
    };
  };
in
  formatter
  // {
    passthru = formatter.passthru;
  }
