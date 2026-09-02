{
  pkgs,
  config,
  internal,
  namespace,
  lib,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.desktop.theme;

  cursorTheme = {
    name = "Qogir";
    size = 32;
    package = pkgs.qogir-icon-theme;
  };

  catppuccinAccent = "blue";
  catppuccinFlavor = "macchiato";

  catppuccinKvantum = pkgs.catppuccin-kvantum.override {
    accent = catppuccinAccent;
    variant = catppuccinFlavor;
  };
in
{
  options.${namespace}.desktop.theme = with types; {
    enable = mkBoolOpt false "Desktop theme management - unified theming for GTK, Qt, and terminal applications";
    fonts = mkOpt (listOf package) [ ] "Custom font packages to install.";
  };

  config = mkIf cfg.enable {
    home = {
      sessionVariables = {
        XCURSOR_THEME = cursorTheme.name;
        XCURSOR_SIZE = "${toString cursorTheme.size}";
      };

      pointerCursor = cursorTheme // {
        gtk.enable = true;
        x11.enable = true;
      };

      packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        cursorTheme.package
        catppuccinKvantum
        papirus-folders
      ];
    };

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "JetBrains Mono" ];
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
        };
      };
    };

    gtk = {
      enable = true;

      gtk3 = {
        extraConfig.gtk-application-prefer-dark-theme = true;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };
  };
}
