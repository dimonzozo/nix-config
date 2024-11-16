{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;

  cfg = config.${namespace}.cli-apps.lazygit;
in
{
  options.${namespace}.cli-apps.lazygit = {
    enable = mkEnableOption "Lazygit.";
  };

  config = {
    programs.lazygit = {
      enable = true;

      catppuccin = {
        enable = true;
        flavor = "mocha";
      };
    };
  };
}
