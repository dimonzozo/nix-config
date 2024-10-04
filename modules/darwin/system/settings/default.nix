{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.settings;
in
{
  options.${namespace}.system.settings = with types; {
    enable = mkEnableOption "macOS settings";
    remapCapsLockToControl = mkEnableOption "Whether to remap the Caps Lock key to Control.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      system = {
        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = cfg.remapCapsLockToControl;
        };

        # activationScripts run every time you boot the system or execute `darwin-rebuild`
        activationScripts = {
          # TODO: check and maybe use
          # diff = {
          #   supportsDryActivation = true;
          #   text = ''
          #     ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
          #   '';
          # };
          # reload the settings and apply them without the need to logout/login
          postUserActivation.text = ''
            /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
          '';
        };
        checks = {
          verifyNixChannels = false;
        };
        defaults = {
          CustomUserPreferences = {
            "com.apple.AdLib" = {
              allowApplePersonalizedAdvertising = false;
            };
            "com.apple.controlcenter" = {
              BatteryShowPercentage = true;
            };
            "com.apple.desktopservices" = {
              # Avoid creating .DS_Store files on network or USB volumes
              DSDontWriteNetworkStores = true;
              DSDontWriteUSBStores = true;
            };
            "com.apple.finder" = {
              _FXSortFoldersFirst = true;
              FXDefaultSearchScope = "SCcf"; # Search current folder by default
              ShowExternalHardDrivesOnDesktop = false;
              ShowHardDrivesOnDesktop = false;
              ShowMountedServersOnDesktop = false;
              ShowRemovableMediaOnDesktop = false;
            };
            # Prevent Photos from opening automatically
            "com.apple.ImageCapture".disableHotPlug = true;
            "com.apple.screencapture" = {
              location = "~/Downloads";
              type = "png";
            };
            "com.apple.SoftwareUpdate" = {
              AutomaticCheckEnabled = true;
              # Check for software updates daily, not just once per week
              ScheduleFrequency = 1;
              # Download newly available updates in background
              AutomaticDownload = 0;
              # Install System data files & security updates
              CriticalUpdateInstall = 1;
            };
            "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
            # Turn on app auto-update
            "com.apple.commerce".AutoUpdate = true;
          };
          NSGlobalDomain = {
            AppleICUForce24HourTime = true;
            AppleInterfaceStyle = "Dark";
            AppleInterfaceStyleSwitchesAutomatically = false;
            AppleMeasurementUnits = "Centimeters";
            AppleMetricUnits = 1;
            AppleTemperatureUnit = "Celsius";
            InitialKeyRepeat = 15;
            KeyRepeat = 2;
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticDashSubstitutionEnabled = false;
            NSAutomaticPeriodSubstitutionEnabled = false;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = true;
            NSNavPanelExpandedStateForSaveMode = true;
            NSNavPanelExpandedStateForSaveMode2 = true;
          };
          SoftwareUpdate = {
            AutomaticallyInstallMacOSUpdates = false;
          };
          dock = {
            autohide = true;
            orientation = "left";
            # TODO: Configure dock here and make it host specific
            # persistent-apps = [
            #   "/Applications/Brave Browser.app"
            #   "/Users/${username}/Applications/Home Manager Apps/Telegram.app"
            #   "/Users/${username}/Applications/Home Manager Apps/Alacritty.app"
            # ];
            show-recents = false;
            tilesize = 48;
            # Disable hot corners
            wvous-bl-corner = 1;
            wvous-br-corner = 1;
            wvous-tl-corner = 1;
            wvous-tr-corner = 1;
          };
          finder = {
            _FXShowPosixPathInTitle = true;
            FXEnableExtensionChangeWarning = false;
            FXPreferredViewStyle = "Nlsv";
            AppleShowAllExtensions = false;
            AppleShowAllFiles = false;
            QuitMenuItem = true;
            ShowPathbar = false;
            ShowStatusBar = false;
          };
          menuExtraClock = {
            ShowAMPM = false;
            ShowDate = 1; # Always
            Show24Hour = true;
            ShowSeconds = false;
          };
          screensaver = {
            askForPassword = true;
            askForPasswordDelay = 300;
          };
          trackpad = {
            Clicking = true;
            TrackpadRightClick = true; # enable two finger right click
            TrackpadThreeFingerDrag = true; # enable three finger drag
          };
        };
      };
    }
  ]);
}
