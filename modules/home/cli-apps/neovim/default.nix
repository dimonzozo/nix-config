{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.cli-apps.neovim;
in
{
  options.${namespace}.cli-apps.neovim = {
    enable = mkEnableOption "Neovim";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        (dimonzozo.neovim.override {
          extraLuaConfig = ''
            require('telescope').setup({
              defaults = {
                path_display = { "truncate" }
              }
            })
          '';
        })
      ];
    };
  };
}
