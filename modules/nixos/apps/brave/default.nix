{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.brave;
in
{
  options.${namespace}.apps.brave = with types; {
    enable = mkBoolOpt false "Whether or not to enable Brave Browser.";
  };

  config = mkIf cfg.enable {
    internal.home = {
      extraOptions = {
        programs.brave = {
          enable = true;
        };
      };
    };
  };
}
