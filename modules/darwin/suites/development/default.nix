{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.development;
in
{
  options.${namespace}.suites.development = with types; {
    enable = mkBoolOpt false "Whether or not to enable common development configuration.";
  };

  config = mkIf cfg.enable {
    internal = {
      system = {
        apps = {
          enable = true;
        };
        settings = {
          enable = true;
          remapCapsLockToControl = true;
        };
      };
    };
  };
}
