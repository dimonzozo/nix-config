{
  # inputs,
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
  cfg = config.${namespace}.desktop.niri;
in
{
  options.${namespace}.desktop.niri = {
    enable = mkEnableOption "Niri - A scrollable-tiling Wayland compositor.";
  };

  config = mkIf cfg.enable {
    services = {
      accounts-daemon.enable = true;
      devmon.enable = true;
      # power-profiles-daemon.enable = true;
      # udisks2.enable = true;
      upower = {
        enable = true;
        percentageLow = 15;
        percentageCritical = 10;
        percentageAction = 5;
        criticalPowerAction = "Hibernate";
      };
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
          theme = "catppuccin-mocha-mauve";
        };
        defaultSession = "niri";
      };
    };
    # Core X server and Niri configuration
    programs.niri = {
      enable = true;
    };

    # Security settings
    security = {
      polkit.enable = true;
    };

    environment.systemPackages = with pkgs; [
      brightnessctl
      fuzzel
      swaybg
      # swaylock
      # swayidle
      xwayland-satellite
      # inputs.noctalia.packages.${system}.default
      (pkgs.catppuccin-sddm.override {
        flavor = "mocha";
        accent = "mauve";
      })
    ];
  };
}
