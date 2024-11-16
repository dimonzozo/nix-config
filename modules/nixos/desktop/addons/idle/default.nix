{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.addons.idle;
  userCfg = config.${namespace}.user;
  configDir = ".config";
in
{
  options.${namespace}.desktop.addons.idle = {
    enable = mkBoolOpt false "Whether or not to enable idle and lock management.";
    idleTimeout = mkOpt types.int 300 "Timeout in seconds before screensaver starts.";
    dimTimeout = mkOpt types.int 600 "Timeout in seconds before dimming the screen.";
    lockTimeout = mkOpt types.int 900 "Timeout in seconds before locking the screen.";
    dimLevel = mkOpt types.int 0 "Screen brightness level when dimmed (percentage).";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hyprlock
      asciiquarium-transparent
      brightnessctl
    ];

    # Configuration files
    home-manager.users.${config.${namespace}.user.name} = {
      services.hypridle = {
        enable = true;

        settings = {
          general = {
            lock_cmd = "/home/${userCfg.name}/.local/bin/hyprlock_wrapper.sh";
            before_sleep_cmd = "/home/${userCfg.name}/.local/bin/hyprlock_wrapper.sh"; # Optional but recommended
          };

          listener = [
            {
              timeout = cfg.idleTimeout;
              on-timeout = "hyprctl dispatch togglespecialworkspace screensaver";
              on-resume = "if ! pgrep -x hyprlock > /dev/null; then hyprctl dispatch togglespecialworkspace screensaver; fi";
            }
            {
              timeout = cfg.dimTimeout;
              on-timeout = "brightnessctl -s set 10%";
              on-resume = "brightnessctl -r";
            }
            {
              timeout = cfg.lockTimeout;
              on-timeout = "/home/${userCfg.name}/.local/bin/hyprlock_wrapper.sh";
            }
          ];
        };
      };

      systemd.user.services.hypridle-screensaver = {
        Unit = {
          Description = "Hypridle screensaver manager";
          PartOf = "hypridle.service";
          After = "hypridle.service";
        };

        Service = {
          Type = "forking";
          ExecStart = pkgs.writeShellScript "start-screensaver" ''
            if ! hyprctl clients -j | jq -e 'map(select(.class == "kitty_screensaver")) | length > 0'; then
              kitty --class kitty_screensaver -e asciiquarium >/dev/null &
            fi
          '';
          ExecStop = pkgs.writeShellScript "stop-screensaver" ''
            window_id=$(hyprctl clients -j | jq -r '.[] | select(.class == "kitty_screensaver") | .pid')
            if [ ! -z "$window_id" ]; then
                kill -SIGTERM "$window_id" 2>/dev/null
            fi
          '';
        };

        Install = {
          WantedBy = [ "hypridle.service" ];
        };
      };

      home.file.".local/bin/hyprlock_wrapper.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # Lock the screen
          hyprlock --immediate

          # After hyprlock exits (successful unlock), run our cleanup
          hyprctl dispatch togglespecialworkspace screensaver && brightnessctl -r
        '';
      };

      home.file."${configDir}/hypr/hyprlock.conf" = {
        text = ''
          source = $HOME/.config/hypr/macchiato.conf

          $accent = 0xb3$tealAlpha
          $accentAlpha = $tealAlpha
          $font = JetBrains Mono Regular

          general {
              disable_loading_bar = true
              hide_cursor = true
          }

          background {
              monitor =
              color = rgba(0, 0, 0, 0)
          }

          # TIME
          label {
              monitor =
              text = cmd[update:30000] echo "$(date +"%H:%M")"
              color = $text
              font_size = 90
              font_family = $font
              position = -40, -30
              halign = right
              valign = top
              shadow_passes = 2
          }

          input-field {
              monitor =
              size = 400, 70
              outline_thickness = 3
              dots_size = 0.2
              dots_spacing = 0.15
              dots_center = true
              outer_color = $accent
              inner_color = $surface0
              font_color = $text
              fade_on_empty = true
              placeholder_text = <span foreground="##$textAlpha"><i>󰌾 Logged in as </i><span foreground="##$accentAlpha">$USER</span></span>
              hide_input = false
              check_color = $sky
              fail_color = $red
              fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
              capslock_color = $yellow
              position = 0, -20
              halign = center
              valign = center
              shadow_passes = 2
          }
        '';
      };

      # Hyprland config additions
      wayland.windowManager.hyprland.extraConfig = ''
        # Window rules for screensaver
        windowrule = workspace special:screensaver silent,^(kitty_screensaver)$
        windowrule = float,^(kitty_screensaver)$
        windowrule = fullscreen,^(kitty_screensaver)$
        windowrule = noanim,^(kitty_screensaver)$
        windowrule = opacity 1.0 override 1.0 override,^(kitty_screensaver)$
        windowrule = nofocus,^(kitty_screensaver)$
      '';
    };
  };
}
