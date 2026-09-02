{
  config,
  lib,
  internal,
  pkgs,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.desktop.iwgtk;
in
{
  options.${namespace}.desktop.iwgtk = {
    enable = mkEnableOption "iwgtk wireless networking GUI indicator";

    package = mkOption {
      type = types.package;
      default = pkgs.iwgtk;
      defaultText = literalExpression "pkgs.iwgtk";
      description = "The iwgtk package to use.";
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically start iwgtk indicator on login.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "--debug" ];
      description = "Additional command line arguments to pass to iwgtk indicator.";
    };
  };

  config = mkIf cfg.enable {
    # Install iwgtk package and theme icons dependency
    home.packages = with pkgs; [
      cfg.package
      adwaita-icon-theme
    ];

    # Create systemd user service for iwgtk indicator
    systemd.user.services.iwgtk-indicator = {
      Unit = {
        Description = "iwgtk wireless networking GUI indicator";
        Documentation = "man:iwgtk(1)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/iwgtk -i ${escapeShellArgs cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 3;

        # Environment variables for proper desktop integration
        Environment = [
          "PATH=${config.home.profileDirectory}/bin"
        ];
      };

      Install = mkIf cfg.autoStart {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
