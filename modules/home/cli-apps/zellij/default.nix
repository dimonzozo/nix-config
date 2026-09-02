{
  lib,
  internal,
  config,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.cli-apps.zellij;
in
{
  options.${namespace}.cli-apps.zellij = {
    enable = mkEnableOption "Zellij - a terminal workspace with batteries included";
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      # enableFishIntegration = true;
      settings = {
        simplified_ui = true;
        pane_frames = false;
        default_mode = "normal";
        mirror_session = false;
        ui = {
          pane_frames = {
            rounded_corners = false;
            hide_session_name = true;
          };
        };
      };
    };
  };
}
