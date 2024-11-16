{
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.mpv;
in
{
  options.${namespace}.desktop.mpv = with types; {
    enable = mkBoolOpt false "MPV.";
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
