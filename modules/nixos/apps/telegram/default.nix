{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.apps.telegram;
in
{
  options.${namespace}.apps.telegram = {
    enable = lib.mkEnableOption "Telegram";
  };

  config = lib.mkIf cfg.enable { environment.systemPackages = with pkgs; [ telegram-desktop ]; };
}
