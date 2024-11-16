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
  cfg = config.${namespace}.desktop.hyprland;
  # plugins = inputs.hyprland-plugins.packages.${pkgs.system};

  yt = pkgs.writeShellScript "yt" ''
    notify-send "Opening video" "$(wl-paste)"
    mpv "$(wl-paste)"
  '';

  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  screenshot = import ../scripts/screenshot.nix pkgs;
in
{
  options.${namespace}.desktop.hyprland = {
    enable = mkEnableOption "Enable Hyprland configuration.";
  };

  config = mkIf cfg.enable {
    services.gammastep = {
      enable = true;
      provider = "manual";
      latitude = 51.9;
      longitude = 7.6;
      temperature = {
        day = 6500;
        night = 4500;
      };
    };

    xdg.desktopEntries."org.gnome.Settings" = {
      name = "Settings";
      comment = "Gnome Control Center";
      icon = "org.gnome.Settings";
      exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
      categories = [ "X-Preferences" ];
      terminal = false;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
      plugins = [
        # inputs.hyprland-hyprspace.packages.${pkgs.system}.default
        # plugins.hyprexpo
        # plugins.hyprbars
        # plugins.borderspp
      ];

      settings = {
        exec-once = [
          "hyprctl setcursor Qogir 24"
          "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland"
        ];

        monitor = [
          # "eDP-1, 1920x1080, 0x0, 1"
          # "HDMI-A-1, 2560x1440, 1920x0, 1"
          ",preferred,auto,auto"
        ];

        general = {
          layout = "dwindle";
          # layout = "master";
          resize_on_border = true;
          # gaps_in = 5;
          # gaps_out = 10;
          # border_size = 2;
        };

        misc = {
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
        };

        input = {
          kb_layout = "us,ru";
          kb_options = "grp:win_space_toggle,ctrl:nocaps,altwin:swap_alt_win";
          follow_mouse = 1;
          touchpad = {
            clickfinger_behavior = true;
            disable_while_typing = true;
            drag_lock = false;
            middle_button_emulation = true;
            natural_scroll = true;
            scroll_factor = 0.5;
          };
          repeat_delay = 300;
          repeat_rate = 50;
          sensitivity = 0;
          float_switch_override_focus = 2;
        };

        binds = {
          allow_workspace_cycles = true;
        };

        dwindle = {
          pseudotile = "yes";
          preserve_split = "yes";
          # no_gaps_when_only = "yes";
        };

        master = {
          new_status = "inherit";
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_use_r = true;
        };

        windowrulev2 = [
          #   # Force US layout for terminal
          #   "kbd_layout 0,class:^(kitty)$"
          #   # Remember layout for other apps
          #   "kbd_layout toggle,class:.*"
          "opaque, class:^(firefox)$"
          "opaque, class:^(org.qutebrowser.qutebrowser)$"
          "opaque, class:^(mpv)$"
        ];

        windowrule =
          let
            f = regex: "float, ^(${regex})$";
          in
          [
            (f "org.gnome.Calculator")
            (f "org.gnome.Nautilus")
            (f "pavucontrol")
            (f "nm-connection-editor")
            (f "blueberry.py")
            (f "org.gnome.Settings")
            (f "org.gnome.design.Palette")
            (f "Color Picker")
            (f "xdg-desktop-portal")
            (f "xdg-desktop-portal-gnome")
            (f "com.github.Aylur.ags")
            (f "kitty_dropdown")
            (f "claude_popup")
            # "workspace 7, title:Spotify"
          ];

        bind =
          let
            binding =
              mod: cmd: key: arg:
              "${mod}, ${key}, ${cmd}, ${arg}";
            ws = binding "SUPER" "workspace";
            mvtows = binding "SUPER SHIFT" "movetoworkspace";
            e = "exec, ags -b hypr";
            arr = [
              1
              2
              3
              4
              5
              6
              7
            ];
          in
          [
            # System and Session Control
            "CTRL ALT, Delete, exit"
            "CTRL SHIFT, R, ${e} quit; ags -b hypr"
            ",XF86PowerOff, ${e} -r 'powermenu.sleep()'"
            "SUPER CTRL, Q, exec, hyprctl kill"

            # Launchers and Menus
            "SUPER, R, ${e} -t launcher"
            "CONTROL, SPACE, ${e} -t launcher"

            # Media and Screenshots
            ",XF86Launch4, ${e} -r 'recorder.start()'"
            ",Print, exec, ${screenshot}"
            "SHIFT,Print, exec, ${screenshot} --full"

            # Layout Control
            "SUPER CTRL, J, togglesplit"
            "SUPER, P, pseudo"
            "SUPER, T, togglefloating"
            "SUPER, M, exec, hyprctl dispatch layoutmsg master"
            "SUPER, Return, layoutmsg, swapwithmaster"
            "SUPER, F, fullscreen"
            "SUPER, grave, exec, pypr toggle term"

            # Window Management
            "SUPER, q, killactive"
            "SUPER, G, togglegroup"
            "SUPER SHIFT, G, changegroupactive"
            "SUPER, Z, exec, pypr zoom"

            # Focus Navigation
            "SUPER, h, movefocus, l"
            "SUPER, l, movefocus, r"
            "SUPER, k, movefocus, u"
            "SUPER, j, movefocus, d"
            "SUPER, Tab, focuscurrentorlast"
            "SUPER, Tab, bringactivetotop"

            # Window Movement
            "SUPER SHIFT, h, movewindow, l"
            "SUPER SHIFT, l, movewindow, r"
            "SUPER SHIFT, k, movewindow, u"
            "SUPER SHIFT, j, movewindow, d"

            # Special Workspace
            "SUPER, S, togglespecialworkspace"
            "SUPER SHIFT, S, movetoworkspace, special"
            "SUPER, O, togglespecialworkspace, screensaver"

            # Applications
            "SUPER, B, exec, qutebrowser"
            "SUPER SHIFT, B, exec, firefox"
            "SUPER SHIFT, T, exec, telegram-desktop"
            "SUPER, E, exec, kitty"

            # Input and Layout
            "SUPER, SPACE, exec, hyprctl switchxkblayout next"
          ]
          ++ (map (i: ws (toString i) (toString i)) arr)
          ++ (map (i: mvtows (toString i) (toString i)) arr);

        bindle = [
          ",XF86MonBrightnessUp,   exec, ${brightnessctl} set +5%"
          ",XF86MonBrightnessDown, exec, ${brightnessctl} set  5%-"
          ",XF86KbdBrightnessUp,   exec, ${brightnessctl} -d asus::kbd_backlight set +1"
          ",XF86KbdBrightnessDown, exec, ${brightnessctl} -d asus::kbd_backlight set  1-"
          ",XF86AudioRaiseVolume,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        ];

        # Resize submap
        # submap = {
        #   resize = {
        #     bind = [
        #       ", h, resizeactive, -10 0"
        #       ", l, resizeactive, 10 0"
        #       ", j, resizeactive, 0 10"
        #       ", k, resizeactive, 0 -10"
        #       ", escape, submap, reset"
        #     ];
        #   };
        # };

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER SHIFT, mouse:272, resizewindow"
        ];

        decoration = {
          rounding = 10;

          dim_inactive = false;

          active_opacity = 0.9;
          inactive_opacity = 0.9;
          fullscreen_opacity = 1.0;

          blur = {
            enabled = true;
            size = 8;
            passes = 3;
            new_optimizations = "on";
            noise = 1.0e-2;
            contrast = 0.9;
            brightness = 0.8;
            popups = true;
          };
        };

        animations = {
          enabled = "yes";
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 5, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
            "specialWorkspace, 1, 3, default, fade"
          ];
        };

        plugin = {
          overview = {
            centerAligned = true;
            hideTopLayers = true;
            hideOverlayLayers = true;
            showNewWorkspace = true;
            exitOnClick = true;
            exitOnSwitch = true;
            drawActiveWorkspace = true;
            reverseSwipe = true;
          };
          hyprbars = {
            bar_color = "rgb(2a2a2a)";
            bar_height = 28;
            col_text = "rgba(ffffffdd)";
            bar_text_size = 11;
            bar_text_font = "Ubuntu Nerd Font";

            buttons = {
              button_size = 0;
              "col.maximize" = "rgba(ffffff11)";
              "col.close" = "rgba(ff111133)";
            };
          };
        };
      };
    };
  };
}
