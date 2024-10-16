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
  cfg = config.${namespace}.desktop.macos;
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.${namespace}.desktop.macos = {
    enable = mkEnableOption "Setup MacOS home settings.";
  };

  config = mkIf cfg.enable {
    targets.darwin = mkIf isDarwin {
      currentHostDefaults = {
        NSGlobalDomain = {
          AppleLanguages = [ "en-US" ];
          AppleLocale = "en_US";
        };
        "com.apple.Safari" = {
          AutoFillCreditCardData = false;
          AutoFillFromAddressBook = false;
          AutoFillMiscellaneousForms = false;
          AutoFillPasswords = false;
          # Prevent Safari from opening ‘safe’ files automatically after downloading
          AutoOpenSafeDownloads = false;
          IncludeInternalDebugMenu = true;
          IncludeDevelopMenu = true;
          # Privacy: don’t send search queries to Apple
          SuppressSearchSuggestions = true;
          UniversalSearchEnabled = false;
          ShowFavoritesBar = false;
          ShowFullURLInSmartSearchField = true;
          ShowOverlayStatusBar = true;
          WarnAboutFraudulentWebsites = true;
          WebAutomaticSpellingCorrectionEnabled = false;
          WebContinuousSpellCheckingEnabled = true;
          WebKitDeveloperExtrasEnabledPreferenceKey = true;
          WebKitJavaEnabled = false;
          WebKitJavaScriptCanOpenWindowsAutomatically = false;
        };
      };
    };
  };
}
