{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.tools.bottom;
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.${namespace}.tools.bottom = {
    enable = mkEnableOption "Bottom.";
  };

  config = mkIf cfg.enable {
    programs = {
      bottom = {
        enable = true;
        catppuccin = {
          enable = true;
          flavor = "mocha";
        };
      };
    };
  };
}
