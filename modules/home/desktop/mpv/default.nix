{
  pkgs,
  config,
  namespace,
  lib,
  internal,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.desktop.mpv;
in
{
  options.${namespace}.desktop.mpv = with types; {
    enable = mkBoolOpt false "MPV - a free, open source, and cross-platform media player";
  };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;

      config = {
        hwdec = "auto-safe";
        vo = "gpu";
        profile = "fast";
        gpu-context = "wayland";
      };
    };
  };
}
