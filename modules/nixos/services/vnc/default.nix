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
  cfg = config.${namespace}.services.vnc;
in
{
  options.${namespace}.services.vnc = {
    enable = mkEnableOption "VNC server";
    user = mkOption {
      type = types.str;
      description = "User to run VNC services";
    };
    shell = mkOption {
      type = types.str;
      default = "${pkgs.fish}/bin/fish";
      description = "Shell for VNC session";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/vnc/.cache 0700 ${cfg.user} ${cfg.user} -"
    ];

    services.xserver = {
      enable = true;
      displayManager = {
        startx.enable = false;
      };
      desktopManager.xfce.enable = true;
    };

    systemd.services = {
      "vnc-xorg" = {
        description = "X Server for VNC on HDMI dummy";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.xorg.xorgserver}/bin/Xorg :1 -noreset -auth /home/${cfg.user}/.Xauthority";
          Restart = "always";
          RestartSec = "10";
        };
      };

      "vnc-xfce" = {
        description = "XFCE for VNC";
        after = [ "vnc-xorg.service" ];
        requires = [ "vnc-xorg.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          PAMName = "login";
          Environment = [
            "DISPLAY=:1"
            "SHELL=${cfg.shell}"
            "XDG_SESSION_TYPE=x11"
            "DESKTOP_SESSION=xfce"
          ];
          ExecStart = "${pkgs.xfce.xfce4-session}/bin/startxfce4";
          Restart = "always";
          RestartSec = "5";
        };
      };

      "vnc-server" = {
        description = "VNC Server";
        after = [
          "vnc-xorg.service"
          "vnc-xfce.service"
        ];
        requires = [
          "vnc-xorg.service"
          "vnc-xfce.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Environment = "DISPLAY=:1";
          ExecStart = "${pkgs.tigervnc}/bin/x0vncserver -display :1 -localhost -PasswordFile \${HOME}/.config/vnc/passwd";
          Restart = "always";
          RestartSec = "5";
        };
      };
    };

    # Enable D-Bus service for XFCE
    services.dbus.enable = true;

    environment.systemPackages = with pkgs; [
      tigervnc
      xorg.xorgserver
      xfce.xfce4-panel
      xfce.xfce4-session
      xfce.xfce4-settings
      xfce.xfdesktop
      xfce.xfwm4
      xfce.xfce4-terminal
      xfce.thunar
      xorg.xinit
      xorg.xauth
      dbus
    ];
  };
}
