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

  # Panel geometry copied verbatim from toussaint, where these are logical
  # pixels against a 960 px screen height (plasmashellrc keeps them under
  # [PlasmaViews][Panel 2][Vertical960]). If a host's display makes the panel
  # look wrong, these four numbers are the only thing to retune.
  panelGeometry = {
    thickness = 40;
    minLength = 634;
    maxLength = 706;
    offset = 108;
  };

  desktopNumbers = range 1 9;

  # Meta+<n> switches virtual desktop. These digits are stock bindings for the
  # icon tasks entries, so those have to be unbound below.
  switchToDesktop = listToAttrs (
    map (n: nameValuePair "Switch to Desktop ${toString n}" "Meta+${toString n}") desktopNumbers
  );

  # Meta+Shift+<n> sends the active window to desktop <n>. KDE records the
  # shifted digit rather than the modifier, hence the spelled-out symbols.
  windowToDesktop = listToAttrs (
    zipListsWith nameValuePair (map (n: "Window to Desktop ${toString n}") desktopNumbers) [
      "Meta+!"
      "Meta+@"
      "Meta+#"
      "Meta+$"
      "Meta+%"
      "Meta+^"
      "Meta+&"
      "Meta+*"
      "Meta+("
    ]
  );

  # Frees Meta+<n> for the virtual desktop switcher above.
  unbindTaskManagerEntries = listToAttrs (
    map (n: nameValuePair "activate task manager entry ${toString n}" "none") desktopNumbers
  );

  mkPictureInPictureRule =
    {
      name,
      windowClass,
      title,
    }:
    {
      description = "Window settings for ${name} picture-in-picture";
      match = {
        window-class = {
          value = windowClass;
          type = "exact";
          # Match the class alone, not the "class name" pair.
          match-whole = false;
        };
        title = {
          value = title;
          type = "exact";
        };
        window-types = [ "normal" ];
      };
      apply = {
        above = {
          value = true;
          apply = "force";
        };
        skiptaskbar = {
          value = true;
          apply = "force";
        };
        skippager = {
          value = true;
          apply = "force";
        };
        skipswitcher = {
          value = true;
          apply = "force";
        };
        # "\0" is how KWin spells "on all desktops".
        desktops = {
          value = "\\0";
          apply = "force";
        };
      };
    };
in
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  options.${namespace}.desktop.plasma = with types; {
    enable = mkBoolOpt false "KDE Plasma user configuration managed via plasma-manager";
    overrideConfig = mkBoolOpt false "Discard KDE settings made outside plasma-manager";
    appDashboard = mkBoolOpt true "Application Dashboard (kickerdash) widget on the desktop";
    lightweightEffects = mkBoolOpt false "Disable window and desktop animations, for hosts without GPU acceleration";
  };

  config = mkIf cfg.enable {
    programs.plasma = {
      enable = true;
      inherit (cfg) overrideConfig;

      # kcminputrc holds pointer and touchpad calibration keyed by per-machine
      # device IDs, which cannot be expressed here. Keep it across activations
      # even when overrideConfig owns everything else.
      resetFilesExclude = [ "kcminputrc" ];

      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        colorScheme = "BreezeDark";
        iconTheme = "breeze-dark";
        widgetStyle = "Breeze";
        theme = "default";
        cursor.theme = "breeze_cursors";

        # Picture of the Day wallpaper, same as "Simon Stålenhag Wallpapers"
        # provider in the Folder View settings dialog.
        wallpaperPictureOfTheDay = {
          provider = "simonstalenhag";
          updateOverMeteredConnection = false;
        };
        # "Scaled and Cropped" positioning in the KDE dialog (FillMode=2).
        wallpaperFillMode = "preserveAspectCrop";
      };

      input.keyboard = {
        repeatDelay = 200;
        repeatRate = 20.0;
      };

      kwin = {
        virtualDesktops = {
          number = 5;
          rows = 1;
        };

        nightLight = {
          enable = true;
          temperature = {
            day = 6000;
            night = 4000;
          };
        };

        effects = mkMerge [
          {
            shakeCursor.enable = false;
          }
          (mkIf (!cfg.lightweightEffects) {
            windowOpenClose.animation = "fade";
            desktopSwitching.animation = "fade";
          })
          (mkIf cfg.lightweightEffects {
            windowOpenClose.animation = "off";
            desktopSwitching.animation = "off";
            blur.enable = false;
            translucency.enable = false;
            slideBack.enable = false;
          })
        ];
      };

      krunner = {
        # "Free floating" rather than docked to the top of the screen.
        position = "center";
        activateWhenTypingOnDesktop = false;
        shortcuts.launch = "Ctrl+Space";
      };

      spectacle.shortcuts.recordRegion = "Meta+Shift+R";

      session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

      kscreenlocker.timeout = 30;

      powerdevil = {
        AC = {
          turnOffDisplay.idleTimeout = 1500;
          autoSuspend.idleTimeout = 1800;
        };
        battery = {
          dimDisplay = {
            enable = true;
            idleTimeout = 300;
          };
          turnOffDisplay.idleTimeout = 1500;
          autoSuspend.idleTimeout = 1800;
          powerProfile = "balanced";
        };
        lowBattery = {
          displayBrightness = 20;
          powerProfile = "powerSaving";
          # toussaint hibernates here; no host running this module has working
          # hibernation, so sleep instead.
          autoSuspend.action = "sleep";
          whenLaptopLidClosed = "sleep";
        };
      };

      shortcuts = {
        "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Space";

        # Never log out, reboot or power off from the keyboard.
        ksmserver = {
          "LogOut" = "none";
          "Log Out Without Confirmation" = "none";
          "Reboot" = "none";
          "Reboot Without Confirmation" = "none";
          "Shut Down" = "none";
          "Halt Without Confirmation" = "none";
        };

        kwin = {
          # Meta is reserved for window and desktop management, so the
          # overview effects keep only their Ctrl+F-key bindings.
          "Expose" = "Ctrl+F9";
          "ExposeAll" = [
            "Ctrl+F10"
            "Launch (C)"
          ];
          "ExposeClass" = "Ctrl+F7";

          "Switch One Desktop to the Left" = "Meta+Shift+Left";
          "Switch One Desktop to the Right" = "Meta+Shift+Right";
          # Frees Meta+Shift+Left/Right for the two above.
          "Window to Next Screen" = "none";
          "Window to Previous Screen" = "none";

          "Walk Through Windows" = "Meta+Tab";
          "Walk Through Windows (Reverse)" = "Meta+Shift+Tab";
          "Walk Through Windows of Current Application" = "Alt+`";
          "Walk Through Windows of Current Application (Reverse)" = "Alt+~";

          "Window Close" = [
            "Alt+F4"
            "Meta+Q"
          ];
        }
        // switchToDesktop
        // windowToDesktop;

        plasmashell = {
          "activate application launcher" = "Alt+F1";
          # Frees Meta+Q for Window Close.
          "manage activities" = "none";
          "next activity" = "Meta+A";
          "previous activity" = "Meta+Shift+A";
          # Clipboard popup; the clipboard widget is disabled entirely.
          "show-on-mouse-pos" = "none";
        }
        // unbindTaskManagerEntries;
      };

      # Declaring panels makes plasma-manager own them: the default bottom
      # panel is replaced by this single left-side one.
      panels = [
        {
          location = "left";
          # Qt::AlignLeft, which for a vertical panel means top-anchored.
          alignment = "left";
          hiding = "autohide";
          floating = false;
          opacity = "adaptive";
          # Panel thickness ("width" for a vertical panel).
          height = panelGeometry.thickness;
          minLength = panelGeometry.minLength;
          maxLength = panelGeometry.maxLength;
          offset = panelGeometry.offset;
          widgets = [
            "org.kde.plasma.kickoff"
            {
              iconTasks = {
                launchers = [ ];
                appearance.fill = false;
              };
            }
            "org.kde.plasma.panelspacer"
            {
              systemTray.items = {
                # Pinned to the bar rather than hidden in the popup.
                shown = [
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.brightness"
                  "org.twosheds.iwgtk"
                  "org.kde.plasma.battery"
                ];
                hidden = [
                  "JavaEmbeddedFrame"
                  "TelegramDesktop"
                ];
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
                  "org.kde.plasma.bluetooth"
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
                date.format.custom = "MM/dd";
                calendar = {
                  firstDayOfWeek = "monday";
                  showWeekNumbers = true;
                  plugins = [ "holidaysevents" ];
                };
                timeZone.selected = [ "Europe/Berlin" ];
              };
            }
          ];
        }
      ];

      desktop = {
        # Desktop icons stay wherever they are dropped.
        icons.sorting.mode = "manual";

        # The full-screen application dashboard, parked on the desktop so it
        # can own a global shortcut. The applet id is generated by Plasma, so
        # the shortcut has to be set on the widget object rather than declared
        # as "activate widget <n>" in kglobalshortcutsrc.
        widgets = mkIf cfg.appDashboard [
          {
            name = "org.kde.plasma.kickerdash";
            position = {
              horizontal = 1264;
              vertical = 112;
            };
            size = {
              width = 64;
              height = 64;
            };
            extraConfig = ''
              (widget) => { widget.globalShortcut = "Meta+R"; }
            '';
          }
        ];
      };

      window-rules = [
        {
          description = "Window settings for kitty";
          match = {
            window-class = {
              value = "kitty";
              type = "exact";
              match-whole = false;
            };
            window-types = [ "normal" ];
          };
          apply.noborder = {
            value = true;
            apply = "force";
          };
        }
        (mkPictureInPictureRule {
          name = "firefox";
          windowClass = "firefox";
          title = "Picture-in-Picture";
        })
        (mkPictureInPictureRule {
          name = "chromium";
          windowClass = "chromium";
          title = "Picture in picture";
        })
      ];

      configFile = {
        kwinrc = {
          # Disable all active screen corners/edges.
          "Effect-overview".BorderActivate = 9;
          TabBox = {
            BorderActivate = 9;
            BorderAlternativeActivate = 9;
            DesktopMode = 0;
            LayoutName = "big_icons";
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
          Plugins = {
            loginEnabled = false;
            logoutEnabled = false;
            screenedgeEnabled = false;
          };
          Xwayland.Scale = 2;
        };

        kdeglobals = {
          General = {
            TerminalApplication = "kitty";
            TerminalService = "kitty.desktop";
            UseSystemBell = true;
            XftAntialias = true;
            XftHintStyle = "hintslight";
            XftSubPixel = "rgb";
          };
          KDE.ShowDeleteCommand = false;
          KScreen.ScreenScaleFactors = {
            value = "eDP-1=1;";
            # KDE stores this verbatim; escaping would turn "=" into \x3d.
            escapeValue = false;
          };
          Shortcuts.Copy = "Ctrl+Ins; Ctrl+C";
          PreviewSettings = {
            EnableRemoteFolderThumbnail = false;
            MaximumRemoteSize = 0;
          };
          "KFileDialog Settings" = {
            "Allow Expansion" = false;
            "Automatically select filename extension" = true;
            "Breadcrumb Navigation" = true;
            "Decoration position" = 2;
            "Show Full Path" = false;
            "Show Inline Previews" = true;
            "Show Preview" = false;
            "Show Speedbar" = true;
            "Show hidden files" = false;
            "Sort by" = "Date";
            "Sort directories first" = true;
            "Sort hidden files last" = false;
            "Sort reversed" = false;
            "Speedbar Width" = 140;
            "View Style" = "DetailTree";
          };
        };

        baloofilerc."Basic Settings"."Indexing-Enabled" = false;
        krunnerrc.Plugins.baloosearchEnabled = false;

        # Use one common display style for all folders in Dolphin. This has no
        # counterpart on toussaint, where per-folder view properties were left
        # to drift.
        dolphinrc = {
          General = {
            GlobalViewProps = true;
            UseTabForSwitchingSplitView = true;
          };
          # 16 px is Dolphin's minimum icon/preview size.
          DetailsMode = {
            IconSize = 16;
            PreviewSize = 16;
          };
          MainWindow.MenuBar = "Disabled";
          PreviewSettings.Plugins = "directorythumbnail,imagethumbnail,jpegthumbnail,svgthumbnail";
          "KFileDialog Settings" = {
            "Places Icons Auto-resize" = false;
            "Places Icons Static Size" = 22;
          };
        };

        klipperrc.General = {
          KeepClipboardContents = false;
          MaxClipItems = 1;
        };

        plasma-localerc.Formats.LANG = "en_US.UTF-8";
        plasma_calendar_holiday_regions.General.selectedRegions = "de-nw_de";

        plasmanotifyrc = {
          Notifications.PopupPosition = "BottomRight";
          "Services/donationmessage" = {
            ShowInHistory = false;
            ShowPopups = false;
          };
        };

        # Do not track which files and applications were used when.
        kactivitymanagerdrc.Plugins."org.kde.ActivityManager.ResourceScoringEnabled" = false;
        kactivitymanagerd-pluginsrc."Plugin-org.kde.ActivityManager.Resources.Scoring".what-to-remember = 2;
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
