{
  config,
  lib,
  internal,
  namespace,
  pkgs,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.system.locale;
in
{
  options.${namespace}.system.locale = with types; {
    enable = mkBoolOpt false "Whether or not to manage locale settings.";
    termFont = mkOpt types.str "ter-v32n" "Terminal font to use.";
  };

  config = mkIf cfg.enable {
    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "de_DE.UTF-8/UTF-8"
      ];
    };

    console = {
      font = cfg.termFont;
      keyMap = mkForce "us";
      packages = [ pkgs.terminus_font ];
      earlySetup = true;
    };
  };
}
