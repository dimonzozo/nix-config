{
  lib,
  pkgs,
  internal,
  config,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.desktop.plasma;
in
{
  options.${namespace}.desktop.plasma = {
    enable = mkEnableOption "KDE Plasma Desktop Environment";
  };

  config = mkIf cfg.enable {
    services = {
      desktopManager.plasma6 = {
        enable = true;
      };
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        defaultSession = "plasma";
      };
    };

    security = {
      polkit.enable = true;
      pam.services.plasma.enableKwallet = true;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];
  };
}
