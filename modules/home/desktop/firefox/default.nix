{
  config,
  lib,
  internal,
  namespace,
  pkgs,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.desktop.firefox;
in
{
  options.${namespace}.desktop.firefox = with types; {
    enable = mkBoolOpt false "Firefox - open-source web browser";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-darwin;

      profiles = {
        default = {
          id = 0;
          isDefault = true;
          settings = {
            # Content blocking and privacy
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "locked";
            };

            # Form settings
            "browser.formfill.enable" = false;

            # UI settings
            "browser.fullscreen.autohide" = false;

            # New tab settings
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.snippets" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;

            # Search settings
            "browser.search.suggest.enabled" = false;
            "browser.search.suggest.enabled.private" = false;
            "browser.topsites.contile.enabled" = false;
            "browser.urlbar.showSearchSuggestionsFirst" = false;
            "browser.urlbar.suggest.searches" = false;

            # Feature settings
            "extensions.pocket.enabled" = false;
            "extensions.screenshots.disabled" = true;
          };
        };
      };
    };
  };
}
