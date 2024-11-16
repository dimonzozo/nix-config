{
  pkgs,
  lib,
  namespace,
  config,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.fonts;
in
{
  options.${namespace}.system.fonts = with types; {
    enable = mkBoolOpt false "Whether or not to manage fonts.";
    fonts = mkOpt (listOf package) [ ] "Custom font packages to install.";
  };

  config = mkIf cfg.enable {
    fonts = {
      # fontconfig.enable = true;
      packages =
        with pkgs;
        [
          (nerdfonts.override {
            fonts = [
              "Hack"
              "FiraCode"
              "NerdFontsSymbolsOnly"
            ];
          })
          fira
          font-awesome
          jetbrains-mono
        ]
        ++ cfg.fonts;
    };
  };
}
