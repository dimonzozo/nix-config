{
  lib,
  namespace,
  config,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.apps;
in
{
  options.${namespace}.system.apps = with types; {
    enable = mkBoolOpt false "Whether or not to manage homebrew cask apps.";
    extra = mkOpt (listOf package) [ ] "Custom apps to install.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false;
        upgrade = false;
        # cleanup = "zap";
      };

      casks = [
        "alacritty"
        "microsoft-office"
        "roon"
        "vlc"
        "exodus"
        "microsoft-teams"
        "steam"
        "vscodium"
        "miro"
        "telegram"
        "microsoft-auto-update"
        "prosys-opc-ua-browser"
        "viscosity"
      ] ++ cfg.extra;
    };
  };
}
