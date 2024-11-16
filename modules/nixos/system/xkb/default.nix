{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.xkb;
in
{
  options.${namespace}.system.xkb = with types; {
    enable = mkBoolOpt false "Whether or not to configure xkb.";
  };

  config = mkIf cfg.enable {
    console.useXkbConfig = true;

    services.xserver.xkb = {
      layout = "us,ru";
      options = "grp:win_space_toggle,custom:mac-like,ctrl:nocaps,altwin:swap_alt_win";
    };
  };
}
