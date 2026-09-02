{
  options,
  config,
  pkgs,
  lib,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.services.printing;
in
{
  options.${namespace}.services.printing = with types; {
    enable = mkBoolOpt false "Whether or not to configure printing support.";
  };

  config = mkIf cfg.enable { services.printing.enable = true; };
}
