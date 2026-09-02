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
    enable = mkEnableOption "Lazygit - simple terminal UI for git commands";
  };

  config = {
    programs.lazygit = {
      enable = true;
      settings = {
        git = {
          autoFetch = false;
        };
      };
    };
  };
}
