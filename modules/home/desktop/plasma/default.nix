{
  inputs,
  config,
  namespace,
  lib,
  internal,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.desktop.plasma;
in
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  options.${namespace}.desktop.plasma = with types; {
    enable = mkBoolOpt false "KDE Plasma user configuration managed via plasma-manager";
  };

  config = mkIf cfg.enable {
    programs.plasma = {
      enable = true;

      workspace = {
        # Picture of the Day wallpaper, same as "Simon Stålenhag Wallpapers"
        # provider in the Folder View settings dialog.
        wallpaperPictureOfTheDay = {
          provider = "simonstalenhag";
          updateOverMeteredConnection = false;
        };
        # "Scaled" positioning in the KDE dialog.
        wallpaperFillMode = "stretch";
      };

      input.keyboard = {
        repeatDelay = 300;
        repeatRate = 25.0;
      };

      # Declaring panels makes plasma-manager own them: the default bottom
      # panel is replaced by this single left-side one.
      panels = [
        {
          location = "left";
          hiding = "autohide";
          # Panel thickness ("width" for a vertical panel).
          height = 54;
          # Equal min/max pin the panel to a fixed length (vertical panel, so
          # this is its on-screen height in pixels); implies lengthMode "custom".
          minLength = 1000;
          maxLength = 1000;
          widgets = [
            "org.kde.plasma.kickoff"
            "org.kde.plasma.icontasks"
            "org.kde.plasma.marginsseparator"
            {
              systemTray.items = {
                # Explicit allowlist of tray entries; org.kde.plasma.clipboard
                # is omitted, which disables the widget and klipper history.
                extra = [
                  "org.kde.plasma.cameraindicator"
                  "org.kde.plasma.devicenotifier"
                  "org.kde.plasma.manage-inputmethod"
                  "org.kde.plasma.mediacontroller"
                  "org.kde.plasma.notifications"
                  "org.kde.kscreen"
                  "org.kde.plasma.battery"
                  "org.kde.plasma.brightness"
                  "org.kde.plasma.keyboardindicator"
                  "org.kde.plasma.keyboardlayout"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.weather"
                ];
              };
            }
            {
              digitalClock = {
                time.format = "24h";
                date.enable = false;
                calendar.firstDayOfWeek = "monday";
                timeZone.selected = [ "Europe/Berlin" ];
              };
            }
          ];
        }
      ];

      window-rules = [
        {
          description = "kitty: hide titlebar and frame";
          match.window-class = {
            value = "kitty";
            type = "substring";
          };
          apply.noborder = {
            value = true;
            apply = "force";
          };
        }
      ];

      configFile = {
        kwinrc = {
          # Disable all active screen corners/edges.
          "Effect-overview".BorderActivate = 9;
          TabBox = {
            BorderActivate = 9;
            BorderAlternativeActivate = 9;
          };
          ElectricBorders = {
            TopLeft = "None";
            Top = "None";
            TopRight = "None";
            Left = "None";
            Right = "None";
            BottomLeft = "None";
            Bottom = "None";
            BottomRight = "None";
          };
        };

        baloofilerc."Basic Settings"."Indexing-Enabled" = false;

        # Use one common display style for all folders in Dolphin.
        dolphinrc = {
          General.GlobalViewProps = true;
          # 16 px is Dolphin's minimum icon/preview size.
          DetailsMode = {
            IconSize = 16;
            PreviewSize = 16;
          };
        };

        klipperrc.General = {
          KeepClipboardContents = false;
          MaxClipItems = 1;
        };
      };

      # Global view properties, used for all folders since GlobalViewProps is
      # on. ViewMode: 0 = Icons, 1 = Compact, 2 = Details.
      dataFile."dolphin/view_properties/global/.directory".Dolphin = {
        Version = 4;
        ViewMode = 2;
      };
    };
  };
}
