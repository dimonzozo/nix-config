{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.gnome;

  defaultExtensions = with pkgs.gnomeExtensions; [
    appindicator # legacy tray icons support
    dash-to-dock # customizable dock
    gsconnect # KDE Connect implementation for GNOME
    gtile # window tiling manager
    just-perfection # GNOME Shell customization
    logo-menu # custom menu with logo
    no-overview # disable overview on startup
    # remove-app-menu # removes app menu from top bar
    space-bar # workspace indicator
    top-bar-organizer # customize top bar items
    wireless-hid # Bluetooth device battery indicator
  ];

  default-attrs = mapAttrs (key: mkDefault);
  nested-default-attrs = mapAttrs (key: default-attrs);
in
{
  options.${namespace}.desktop.gnome = with types; {
    enable = mkBoolOpt false "Whether or not to use Gnome as the desktop environment.";
    color-scheme = mkOpt (enum [
      "light"
      "dark"
    ]) "dark" "The color scheme to use.";
    wayland = mkBoolOpt true "Whether or not to use Wayland.";
    suspend = mkBoolOpt true "Whether or not to suspend the machine after inactivity.";
    monitors = mkOpt (nullOr path) null "The monitors.xml file to create.";
    extensions = mkOpt (listOf package) [ ] "Extra Gnome extensions to install.";
  };

  config = mkIf cfg.enable {
    internal.system.xkb.enable = true;
    internal.desktop.addons = {
      clipboard = enabled;
    };

    environment.systemPackages =
      with pkgs;
      [
        baobab # disk usage analyzer and visualization tool
        brightnessctl # brightness control
        gnome-text-editor # simple text editor for GNOME
        adwaita-icon-theme # default GNOME icon theme
        gnome-boxes # virtual machine manager
        gnome-calculator # GNOME calculator app
        gnome-calendar # calendar application for GNOME
        gnome-clocks # world clock and timer app
        gnome-control-center # gnome settings manager
        gnome-system-monitor # process and resource monitor
        gnome-tweaks # gnome customization tool
        gnome-weather # weather forecast application
        nautilus # gnome file manager
        nautilus-python # python bindings for nautilus
        libdbusmenu-gtk3 # gtk3 dbus menu library
        loupe # image viewer for GNOME
        morewaita-icon-theme # extended Adwaita icon theme
        pavucontrol # pulseaudio volume control
        playerctl # media player controller
        qogir-icon-theme # modern icon theme
        rofi # application launcher
        waybar # status bar for wayland
        wayland-logout # wayland session logout utility
        wayshot # screenshot tool for wayland
        wl-gammactl # gamma/brightness control for wayland
        wofi # wayland native application launcher
        wtype # xdotool replacement for wayland
        xwayland # x11 compatibility layer
      ]
      ++ defaultExtensions
      ++ cfg.extensions;

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour # GNOME welcome and feature tour app
      epiphany # GNOME's native web browser
      geary # modern email client for GNOME
      gnome-font-viewer # font preview and information tool
      gnome-system-monitor # system resources and process monitor
      gnome-maps # OpenStreetMap-based maps application
    ];

    environment = {
      sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "Gnome";
        XDG_SESSION_DESKTOP = "Gnome";
        WLR_NO_HARDWARE_CURSORS = "1";
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
        # gnome-online-accounts.enable = true; # online account integration
        localsearch.enable = true; # file indexing service
        tinysparql.enable = true; # metadata database
      };

      xserver.displayManager.gdm.enable = false;

      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd gnome-session";
            user = "greeter";
          };
        };
      };

      # Required for app indicators
      udev.packages = with pkgs; [ gnome-settings-daemon ];

      libinput.enable = true;

      xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
      };
    };

    systemd.tmpfiles.rules = [ "d '/var/cache/greeter' - greeter greeter - -" ];

    internal.home.extraOptions = {
      dconf.settings =
        let
          user = config.users.users.${config.${namespace}.user.name};
        in
        nested-default-attrs {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions =
              (builtins.map (extension: extension.extensionUuid) (cfg.extensions ++ defaultExtensions))
              ++ [
                "native-window-placement@gnome-shell-extensions.gcampax.github.com"
                "drive-menu@gnome-shell-extensions.gcampax.github.com"
                "user-theme@gnome-shell-extensions.gcampax.github.com"
              ];
            favorite-apps =
              [ "org.gnome.Nautilus.desktop" ]
              ++ optional config.${namespace}.apps.firefox.enable "firefox.desktop"
              ++ [ "Kitty.desktop" ]
              ++ optional config.${namespace}.apps._1password.enable "1password.desktop";
          };

          "org/gnome/desktop/interface" = {
            color-scheme = if cfg.color-scheme == "light" then "default" else "prefer-dark";
            enable-hot-corners = false;
          };
          "org/gnome/desktop/peripherals/mouse" = {
            speed = 0.0;
            accel-profile = "flat";
            natural-scroll = true;
          };
          "org/gnome/desktop/peripherals/touchpad" = {
            disable-while-typing = false;
          };
          "org/gnome/desktop/peripherals/keyboard" = {
            delay = lib.home-manager.hm.gvariant.mkUint32 200;
          };
          "org/gnome/desktop/wm/preferences" = {
            num-workspaces = 10;
            resize-with-right-button = true;
          };
          "org/gnome/desktop/wm/keybindings" = {
            switch-to-workspace-1 = [ "<Super>1" ];
            switch-to-workspace-2 = [ "<Super>2" ];
            switch-to-workspace-3 = [ "<Super>3" ];
            switch-to-workspace-4 = [ "<Super>4" ];
            switch-to-workspace-5 = [ "<Super>5" ];
            switch-to-workspace-6 = [ "<Super>6" ];
            switch-to-workspace-7 = [ "<Super>7" ];
            switch-to-workspace-8 = [ "<Super>8" ];
            switch-to-workspace-9 = [ "<Super>9" ];
            switch-to-workspace-10 = [ "<Super>0" ];

            move-to-workspace-1 = [ "<Shift><Super>1" ];
            move-to-workspace-2 = [ "<Shift><Super>2" ];
            move-to-workspace-3 = [ "<Shift><Super>3" ];
            move-to-workspace-4 = [ "<Shift><Super>4" ];
            move-to-workspace-5 = [ "<Shift><Super>5" ];
            move-to-workspace-6 = [ "<Shift><Super>6" ];
            move-to-workspace-7 = [ "<Shift><Super>7" ];
            move-to-workspace-8 = [ "<Shift><Super>8" ];
            move-to-workspace-9 = [ "<Shift><Super>9" ];
            move-to-workspace-10 = [ "<Shift><Super>0" ];
          };
          "org/gnome/shell/keybindings" = {
            # Remove the default hotkeys for opening favorited applications.
            switch-to-application-1 = [ ];
            switch-to-application-2 = [ ];
            switch-to-application-3 = [ ];
            switch-to-application-4 = [ ];
            switch-to-application-5 = [ ];
            switch-to-application-6 = [ ];
            switch-to-application-7 = [ ];
            switch-to-application-8 = [ ];
            switch-to-application-9 = [ ];
            switch-to-application-10 = [ ];
          };
          "org/gnome/mutter" = {
            edge-tiling = false;
            dynamic-workspaces = false;
          };

          "org/gnome/shell/extensions/dash-to-dock" = {
            autohide = true;
            dock-fixed = false;
            dock-position = "BOTTOM";
            pressure-threshold = 200.0;
            require-pressure-to-show = true;
            show-favorites = true;
            hot-keys = false;
          };

          "org/gnome/shell/extensions/just-perfection" = {
            panel-size = 48;
            activities-button = false;
          };

          "org/gnome/shell/extensions/Logo-menu" = {
            hide-softwarecentre = true;

            # Use right click to open Activities.
            menu-button-icon-click-type = 3;

            # Use the NixOS logo.
            menu-button-icon-image = 23;
          };

          "org/gnome/shell/extensions/aylurs-widgets" = {
            background-clock = false;
            battery-bar = false;
            dash-board = false;
            date-menu-date-format = "%H:%M  %B %d";
            date-menu-hide-clocks = true;
            date-menu-hide-system-levels = true;
            date-menu-hide-user = true;

            # Hide the indincator
            date-menu-indicator-position = 2;

            media-player = false;
            media-player-prefer = "firefox";
            notification-indicator = false;
            power-menu = false;
            quick-toggles = false;
            workspace-indicator = false;
          };

          "org/gnome/shell/extensions/top-bar-organizer" = {
            left-box-order = [
              "LogoMenu"
              "menuButton"
              "activities"
              "dateMenu"
              "appMenu"
            ];

            center-box-order = [ "Space Bar" ];

            right-box-order = [
              "keyboard"
              "EmojisMenu"
              "wireless-hid"
              "drive-menu"
              "vitalsMenu"
              "screenRecording"
              "screenSharing"
              "dwellClick"
              "a11y"
              "quickSettings"
            ];
          };

          "org/gnome/shell/extensions/space-bar/shortcuts" = {
            enable-activate-workspace-shortcuts = false;
          };
          "org/gnome/shell/extensions/space-bar/behavior" = {
            show-empty-workspaces = false;
          };

          "org/gnome/shell/extensions/gtile" = {
            show-icon = false;
            grid-sizes = "8x2,4x2,2x2";
          };
        };
    };

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };
}
