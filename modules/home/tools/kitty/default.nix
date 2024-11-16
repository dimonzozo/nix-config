{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.tools.kitty;
in
{
  options.${namespace}.tools.kitty = {
    enable = mkEnableOption "Kitty";
    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 12;
    };
  };

  config = mkIf cfg.enable {
    programs = {
      kitty = {
        enable = true;
        catppuccin = {
          enable = true;
          flavor = "mocha";
        };
        font = {
          name = "FiraCode Nerd Font";
          size = cfg.fontSize;
        };

        # Keybindings as list of strings
        keybindings = {
          "ctrl+plus" = "change_font_size all +2.0";
          "ctrl+minus" = "change_font_size all -2.0";

          # Tab management
          "alt+t" = "new_tab";
          "alt+w" = "close_tab";
          "alt+r" = "set_tab_title";

          # Navigation between tabs
          "alt+[" = "previous_tab";
          "alt+]" = "next_tab";
          "alt+shift+left" = "move_tab_backward";
          "alt+shift+right" = "move_tab_forward";

          # Switch to specific tabs using ALT
          "alt+1" = "goto_tab 1";
          "alt+2" = "goto_tab 2";
          "alt+3" = "goto_tab 3";
          "alt+4" = "goto_tab 4";
          "alt+5" = "goto_tab 5";
          "alt+6" = "goto_tab 6";
          "alt+7" = "goto_tab 7";
          "alt+8" = "goto_tab 8";
          "alt+9" = "goto_tab 9";

          # Clipboard
          "ctrl+v" = "paste_from_clipboard";

          # Screen clear
          "ctrl+l" = "combine : clear_terminal scrollback active : send_text normal \\x0c";
        };

        settings = {
          shell = "fish";

          # prettier resize
          resize_debounce_time = 0;
          # deprecated?
          # resize_draw_strategy = "static";

          # Tab bar styling
          tab_bar_style = "powerline";
          tab_powerline_style = "slanted";
          tab_bar_edge = "bottom";
          tab_bar_margin_width = 0;
          tab_bar_margin_height = "0 0";
          tab_title_template = "{index}: {title}";

          # Disable audio bell
          enable_audio_bell = "no";

          # Disable visual bell (the terminal window flashing)
          visual_bell_duration = "0.0";

          # Optional: Disable terminal bell through OSC (Operating System Command)
          # command_on_bell = "none";

          # Optional: Disable requesting attention on bell
          # window_alert_on_bell = "no";
          # bell_on_tab = "no";

          # Tab colors and style
          active_tab_foreground = "#c0caf5";
          active_tab_background = "#33467c";
          active_tab_font_style = "bold";
          inactive_tab_foreground = "#565f89";
          inactive_tab_background = "#1a1b26";
          inactive_tab_font_style = "normal";

          # Scroll
          touch_scroll_multiplier = "4.0";
          wheel_scroll_multiplier = "4.0";

          # Make the tab bar more minimal
          tab_bar_min_tabs = 2;
          tab_bar_background = "none";
        };
      };
    };
  };
}
