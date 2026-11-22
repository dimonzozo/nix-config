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

  ctp = config.catppuccin.lazygit;

  # The upstream catppuccin theme still uses `gui.authorColors`, which newer
  # lazygit wants migrated to `gui.theme.authorColors`. Lazygit tries to rewrite
  # the file in place, which fails in the read-only store, so migrate it here.
  # Drop this once catppuccin/lazygit ships the new layout.
  ctpTheme =
    pkgs.runCommand "catppuccin-lazygit-${ctp.flavor}-${ctp.accent}.yml"
      { nativeBuildInputs = [ pkgs.yq-go ]; }
      ''
        yq '.gui.theme.authorColors = .gui.authorColors | del(.gui.authorColors)' \
          ${config.catppuccin.sources.lazygit}/${ctp.flavor}/${ctp.accent}.yml > $out
      '';
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

    home.sessionVariables = lib.mkIf (ctp.enable && config.programs.lazygit.enable) {
      LG_CONFIG_FILE = lib.mkForce "${ctpTheme},${config.xdg.configHome}/lazygit/config.yml";
    };
  };
}
