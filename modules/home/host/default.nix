{
  lib,
  internal,
  host ? null,
  namespace,
  ...
}:
let
  inherit (lib) types;
  inherit (internal) mkOpt;
in
{
  options.${namespace}.host = {
    name = mkOpt (types.nullOr types.str) host "The host name.";
  };
}
