{
  options,
  config,
  lib,
  internal,
  pkgs,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.apps.steam;
in
{
  options.${namespace}.apps.steam = with types; {
    enable = mkBoolOpt false "Steam + heroic + bottles";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;

    environment.systemPackages = with pkgs; [
      bottles
      dosbox
      heroic
      mangohud
      protonup-ng
    ];

    programs.gamemode.enable = true;

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/.local/share/Steam/compatibilitytools.d/";
    };
  };
}
