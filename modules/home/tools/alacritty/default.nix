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
  cfg = config.${namespace}.tools.alacritty;
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.${namespace}.tools.alacritty = {
    enable = mkEnableOption "Alacritty";
  };

  config = mkIf cfg.enable {
    programs = mkIf isDarwin {
      alacritty = {
        enable = true;
        catppuccin = {
          enable = true;
          flavor = "mocha";
        };
        # workaround to use homebrew alacritty
        package = pkgs.runCommand "alacritty" { } ''
          mkdir -p $out/bin
          ln -s /opt/homebrew/bin/alacritty $out/bin/alacritty
        '';
        settings = {
          window = {
            decorations = "full";
            startup_mode = "Windowed";
          };
          font =
            let
              font = "FiraCode Nerd Font";
            in
            {
              size = 16;
              normal = {
                family = font;
              };
              bold = {
                family = font;
                style = "Bold";
              };
              italic = {
                family = font;
                style = "Italic";
              };
            };
          cursor = {
            style = "Block";
            unfocused_hollow = true;
          };
          shell = {
            program = "${pkgs.fish}/bin/fish";
            args = [
              "-l"
              "-c"
              "${pkgs.tmux}/bin/tmux attach || ${pkgs.tmux}/bin/tmux"
            ];
          };
          keyboard.bindings = [
            {
              key = "l";
              mods = "Control";
              chars = "\\u0002k";
            }
            {
              key = "Equals";
              mods = "Command";
              action = "IncreaseFontSize";
            }
            {
              key = "Minus";
              mods = "Command";
              action = "DecreaseFontSize";
            }
            {
              key = "V";
              mods = "Command";
              action = "Paste";
            }
            {
              key = "T";
              mods = "Command";
              chars = "\\u0002c";
            }
            {
              key = "W";
              mods = "Command";
              chars = "\\u0002&";
            }
            {
              key = "R";
              mods = "Command";
              chars = "\\u0002,";
            }
            {
              chars = "\\u0002p";
              key = "Left";
              mods = "Shift";
            }
            {
              chars = "\\u0002n";
              key = "Right";
              mods = "Shift";
            }
            {
              chars = "\\u0002p";
              key = "[";
              mods = "Command";
            }
            {
              chars = "\\u0002n";
              key = "]";
              mods = "Command";
            }
            {
              chars = "\\u00021";
              key = "Key1";
              mods = "Command";
            }
            {
              chars = "\\u00022";
              key = "Key2";
              mods = "Command";
            }
            {
              chars = "\\u00023";
              key = "Key3";
              mods = "Command";
            }
            {
              chars = "\\u00024";
              key = "Key4";
              mods = "Command";
            }
            {
              chars = "\\u00025";
              key = "Key5";
              mods = "Command";
            }
            {
              chars = "\\u00026";
              key = "Key6";
              mods = "Command";
            }
            {
              chars = "\\u00027";
              key = "Key7";
              mods = "Command";
            }
            {
              chars = "\\u00028";
              key = "Key8";
              mods = "Command";
            }
            {
              chars = "\\u00029";
              key = "Key9";
              mods = "Command";
            }
          ];
        };
      };
    };
  };
}
