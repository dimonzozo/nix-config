{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.desktop;
in
{
  options.${namespace}.suites.desktop = with types; {
    enable = mkBoolOpt false "Whether or not to enable common desktop configuration.";
  };

  config = mkIf cfg.enable {
    internal = {
      desktop = {
        hyprland.enable = lib.mkDefault true;
      };

      apps = {
        _1password = enabled;
        vlc = enabled;
        telegram = enabled;
        firefox = enabled;
        brave = enabled;
        # vscode = enabled;
        # logseq = enabled;
        # gparted = enabled;
      };
    };
  };
}
