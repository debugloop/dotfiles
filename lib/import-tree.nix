path: let
  entries = builtins.readDir path;
  toList = name: type:
    if type == "directory"
    then import ./import-tree.nix (path + "/${name}")
    else if
      type
      == "regular"
      && builtins.match ".*\\.nix" name != null
      && builtins.match "_.*" name == null
    then [(path + "/${name}")]
    else [];
in
  builtins.concatLists (builtins.attrValues (builtins.mapAttrs toList entries))
