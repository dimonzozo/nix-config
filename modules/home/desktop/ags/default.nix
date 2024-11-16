{
  lib,
  config,
  pkgs,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.ags;
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  options.${namespace}.desktop.ags = {
    enable = mkEnableOption "Enable ags.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bun
      dart-sass
      fd
      brightnessctl
      swww
      inputs.matugen.packages.${system}.default
      slurp
      wf-recorder
      wl-clipboard
      wayshot
      swappy
      hyprpicker
      pavucontrol
      networkmanager
      gtk3
    ];

    programs.ags = {
      enable = true;
      configDir = ../../../../packages/ags-theme;
      extraPackages = with pkgs; [ accountsservice ];
    };

    # Hyprland config additions
    wayland.windowManager.hyprland.extraConfig = ''
      exec-once = ags -b hypr
    '';
  };
}
