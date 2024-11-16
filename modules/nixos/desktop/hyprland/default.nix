{
  config,
  lib,
  pkgs,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.hyprland;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.${namespace}.desktop.hyprland = {
    enable = mkEnableOption "Hyprland";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      displayManager.startx.enable = true;
    };

    internal.desktop.addons = {
      keyring = enabled;
      clipboard = enabled;
      idle = enabled;
      # hyprpanel = enabled;
      pyprland = {
        enable = true;

        scratchpads = {
          term = {
            command = "kitty --class kitty_dropdown";
            animation = "fromTop";
            size = "75% 60%";
            unfocus = "hide";
            excludes = "*";
            lazy = true;
            multi = false;
          };

          #   volume = {
          #     command = "pavucontrol --class volume_sidemenu";
          #     animation = "fromLeft";
          #     class = "volume_sidemenu";
          #     size = "40% 70%";
          #     unfocus = "hide";
          #     excludes = "*";
          #     lazy = true;
          #     margin = 90;
          #     multi = false;
          #   };
          #
          #   claude = {
          #     command = "firefox --new-instance --kiosk --app=https://claude.ai";
          #     animation = "fromTop";
          #     size = "75% 60%";
          #     unfocus = "hide";
          #     lazy = true;
          #     class = "claude_popup";
          #   };
        };

        # Define shortcuts
        shortcuts = {
          "Color picker" = [
            {
              name = "format";
              options = [
                "hex"
                "rgb"
                "hsv"
                "hsl"
                "cmyk"
              ];
            }
            "sleep 0.2; hyprpicker --format [format] -a"
          ];
        };
      };
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr # XDG portal for wlroots-based compositors
        xdg-desktop-portal-gtk # GTK portal backend for screen sharing and more
        xdg-desktop-portal-hyprland # XDG portal specifically for Hyprland
      ];
    };

    security = {
      polkit.enable = true;
      pam.services.ags = { };
    };

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        TDESKTOP_USE_PORTAL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
        GDK_BACKEND = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
      };

      systemPackages = with pkgs; [
        baobab # disk usage analyzer and visualization tool
        brightnessctl # control device brightness
        gnome-text-editor # simple text editor for GNOME
        adwaita-icon-theme # default GNOME icon theme
        gnome-boxes # virtual machine manager
        gnome-calculator # GNOME calculator app
        gnome-calendar # calendar application for GNOME
        gnome-clocks # world clock and timer app
        gnome-control-center # GNOME settings manager
        gnome-system-monitor # process and resource monitor
        gnome-weather # weather forecast application
        nautilus # GNOME file manager
        libnotify # desktop notification library
        loupe # image viewer for GNOME
        morewaita-icon-theme # extended Adwaita icon theme
        pavucontrol # PulseAudio volume control
        playerctl # media player controller
        pyprland # Python plugin system for Hyprland
        qogir-icon-theme # modern icon theme
        swww # efficient wallpaper daemon for Wayland
        wayshot # screenshot tool for Wayland
        wl-gammactl # gamma/brightness control for Wayland
        wtype # xdotool replacement for Wayland
      ];
    };

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    services = {
      accounts-daemon.enable = true; # user account management
      devmon.enable = true; # automatic device mounting daemon
      gvfs.enable = true; # GNOME virtual filesystem
      power-profiles-daemon.enable = true; # power profile switching service
      udisks2.enable = true; # storage device daemon
      upower.enable = true; # power management daemon
      gnome = {
        evolution-data-server.enable = true; # calendar and contacts backend
        glib-networking.enable = true; # network proxy support for GNOME
        gnome-online-accounts.enable = true; # online account integration
        localsearch.enable = true; # file indexing service
        tinysparql.enable = true; # metadata database
      };
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    systemd.tmpfiles.rules = [ "d '/var/cache/greeter' - greeter greeter - -" ];

    system.activationScripts.wallpaper =
      let
        wp = pkgs.writeShellScript "wp" ''
          CACHE="/var/cache/greeter"
          OPTS="$CACHE/options.json"
          HOME="/home/$(find /home -maxdepth 1 -printf '%f\n' | tail -n 1)"

          mkdir -p "$CACHE"
          chown greeter:greeter $CACHE

          if [[ -f "$HOME/.cache/ags/options.json" ]]; then
            cp $HOME/.cache/ags/options.json $OPTS
            chown greeter:greeter $OPTS
          fi

          if [[ -f "$HOME/.config/background" ]]; then
            cp "$HOME/.config/background" $CACHE/background
            chown greeter:greeter "$CACHE/background"
          fi
        '';
      in
      builtins.readFile wp;
  };
}
