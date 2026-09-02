{
  config,
  lib,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.desktop.freetube;
in
{
  options.${namespace}.desktop.freetube = with types; {
    enable = mkBoolOpt false "FreeTube - an open source desktop YouTube app for privacy";
  };

  config = mkIf cfg.enable {
    programs.freetube = {
      enable = true;
    };
  };
}
