{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.apps.thunderbird;
in
{
  options.${namespace}.apps.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.thunderbird;
      description = "Thunderbird package to use";
    };
  };

  config = lib.mkIf cfg.enable { environment.systemPackages = [ cfg.package ]; };
}
