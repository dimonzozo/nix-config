{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.addons.hyprpanel;
in
{
  options.${namespace}.desktop.addons.hyprpanel = with types; {
    enable = mkBoolOpt false "Whether to enable hyprpanel.";
  };

  config = mkIf cfg.enable { environment.systemPackages = [ pkgs.hyprpanel ]; };
}
