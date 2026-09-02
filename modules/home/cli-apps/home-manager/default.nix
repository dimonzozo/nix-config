{
  lib,
  config,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.cli-apps.home-manager;
in
{
  options.${namespace}.cli-apps.home-manager = {
    enable = mkEnableOption "home-manager";
  };

  config = mkIf cfg.enable { programs.home-manager.enable = true; };
}
