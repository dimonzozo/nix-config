{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.freetube;
in
{
  options.${namespace}.desktop.freetube = with types; {
    enable = mkBoolOpt false "Whether or not to enable FreeTube.";
  };

  config = mkIf cfg.enable {
    programs.freetube = {
      enable = true;

      catppuccin = {
        enable = true;
        flavor = "mocha";
      };
    };
  };
}
