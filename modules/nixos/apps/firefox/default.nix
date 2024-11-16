{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  cfg = config.${namespace}.apps.firefox;
in
{
  options.${namespace}.apps.firefox = with types; {
    enable = mkBoolOpt false "Whether or not to enable Firefox.";
  };

  config = mkIf cfg.enable {
    internal.home = {
      extraOptions = {
        programs.firefox = {
          enable = true;
          # languagePacks = [
          #   "de"
          #   "en-US"
          #   "ru"
          # ];

          policies = {
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
            EnableTrackingProtection = {
              Value = true;
              Locked = true;
              Cryptomining = true;
              Fingerprinting = true;
            };
            DisablePocket = true;
            DisableFirefoxAccounts = true;
            DisableAccounts = true;
            DisableFirefoxScreenshots = true;
            OverrideFirstRunPage = "";
            OverridePostUpdatePage = "";
            DontCheckDefaultBrowser = true;
            DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
            DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
            SearchBar = "unified"; # alternative: "separate"

            ExtensionSettings =
              with builtins;
              let
                extension = shortId: uuid: {
                  name = uuid;
                  value = {
                    install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                    installation_mode = "normal_installed";
                  };
                };
              in
              listToAttrs [
                (extension "1password-x-password-manager" "{d634138d-c276-4fc8-924b-40a0ea21d284}")
                (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
                (extension "libredirect" "7esoorv3@alefvanoon.anonaddy.me")
                (extension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
                (extension "tabliss" "extension@tabliss.io")
                (extension "tree-style-tab" "treestyletab@piro.sakura.ne.jp")
                (extension "ublock-origin" "uBlock0@raymondhill.net")
                # (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
                # (extension "umatrix" "uMatrix@raymondhill.net")
              ];
            # To add additional extensions, find it on addons.mozilla.org, find
            # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
            # Then, download the XPI by filling it in to the install_url template, unzip it,
            # run `jq .browser_specific_settings.gecko.id manifest.json` or
            # `jq .applications.gecko.id manifest.json` to get the UUID

            # Check about:config for options.
            Preferences = {
              "browser.contentblocking.category" = {
                Value = "strict";
                Status = "locked";
              };
              "apz.overscroll.enabled" = true;
              "browser.formfill.enable" = lock-false;
              "browser.fullscreen.autohide" = lock-false;
              "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
              "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
              "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
              "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
              "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
              "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
              "browser.newtabpage.activity-stream.showSponsored" = lock-false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
              "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
              "browser.search.suggest.enabled" = lock-false;
              "browser.search.suggest.enabled.private" = lock-false;
              "browser.topsites.contile.enabled" = lock-false;
              "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
              "browser.urlbar.suggest.searches" = lock-false;
              "extensions.pocket.enabled" = lock-false;
              "extensions.screenshots.disabled" = lock-true;
              "general.smoothScroll" = true;
              "general.smoothScroll.currentVelocityWeighting" = "0.1";
              "general.smoothScroll.durationToIntervalRatio" = 1000;
              "general.smoothScroll.lines.durationMaxMS" = 400;
              "general.smoothScroll.lines.durationMinMS" = 200;
              "general.smoothScroll.mouseWheel.durationMaxMS" = 400;
              "general.smoothScroll.mouseWheel.durationMinMS" = 200;
              "general.smoothScroll.other.durationMaxMS" = 400;
              "general.smoothScroll.other.durationMinMS" = 200;
              "general.smoothScroll.pages.durationMaxMS" = 400;
              "general.smoothScroll.pages.durationMinMS" = 200;
              "general.smoothScroll.pixels.durationMaxMS" = 400;
              "general.smoothScroll.pixels.durationMinMS" = 200;
              "general.smoothScroll.scrollbars.durationMaxMS" = 400;
              "general.smoothScroll.scrollbars.durationMinMS" = 200;
              # HW video decoding
              # "gfx.canvas.accelerated.force-enabled" = lock-true;
              # "gfx.webgpu.ignore-blocklist" = lock-true;
              # "media.ffmpeg.vaapi.enabled" = lock-true;
              # "media.hardware-video-decoding.force-enabled" = lock-true;
              "mousewheel.default.delta_multiplier_y" = 75;
              "mousewheel.min_line_scroll_amount" = 25;
              "mousewheel.system_scroll_override.enabled" = true;
              "mousewheel.system_scroll_override_on_root_content.enabled" = true;
            };
          };
        };
      };
    };
  };
}
