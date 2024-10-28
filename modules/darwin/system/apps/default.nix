{
  lib,
  namespace,
  config,
  ...
}:
with lib.${namespace};
let
  cfg = config.${namespace}.system.apps;
in
{
  options.${namespace}.system.apps = with types; {
    enable = mkBoolOpt false "Whether or not to manage homebrew cask apps.";
    msOffice = mkEnableOption "Install MS Office";
    desktopTeams = mkEnableOption "Install Desktop version of MS Teams";
    desktopMiro = mkEnableOption "Install Desktop version of Miro";
    extra = mkOpt (listOf str) [ ] "Custom apps to install.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false;
        upgrade = false;
        # cleanup = "zap";
      };

      casks =
        [
          "alacritty"
          "telegram"
          "raycast"
          "viscosity"
        ]
        ++ lib.optionals cfg.desktopTeams [
          "microsoft-teams"
        ]
        ++ lib.optionals cfg.desktopMiro [
          "miro"
        ]
        ++ lib.optionals cfg.msOffice [
          "microsoft-auto-update"
          "microsoft-office"
        ]
        ++ cfg.extra;
    };
  };
}
