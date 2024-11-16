{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.wallpapers-changer;
in
{
  options.${namespace}.desktop.wallpapers-changer = with types; {
    enable = mkEnableOption "Wallpaper Changer.";
    interval = mkOption {
      type = int;
      default = 7200;
      description = "Interval in seconds between wallpaper changes";
    };
    directory = mkOption {
      type = str;
      default = "~/Downloads/Wallpapers";
      description = "Directory containing wallpapers";
    };
  };

  config = mkIf cfg.enable {
    home.file.".local/bin/wallpaper-changer.py" = {
      executable = true;
      text = ''
        #!/usr/bin/env python3
        import os
        import random
        import subprocess
        import time
        from threading import Timer
        from pathlib import Path

        # Configuration from home-manager
        INTERVAL = ${toString cfg.interval}
        WALLPAPER_DIR = Path("${cfg.directory}").expanduser()

        def run_command(cmd):
            subprocess.run(cmd.split(), check=False)

        def ensure_daemon_running():
            # Check if daemon is running
            if not subprocess.run(["pgrep", "swww-daemon"], capture_output=True).stdout:
                print("Starting swww-daemon")
                # Start daemon in background
                subprocess.Popen(["swww-daemon"], start_new_session=True)
                # Give it a moment to initialize
                time.sleep(INTERVAL)

        def change_wallpaper():
            # Check for disable flag
            if Path("~/.disable-random-wallpaper").expanduser().exists():
                print("~/.disable-random-wallpaper found: script disabled!")
                return

            # Ensure daemon is running
            ensure_daemon_running()

            # Get random wallpaper
            wallpapers = list(WALLPAPER_DIR.glob("*"))
            
            if not wallpapers:
                print(f"No wallpapers found in {WALLPAPER_DIR}")
                return
            
            wallpaper = random.choice(wallpapers)
            run_command(f"swww img {wallpaper} --transition-type random")
            
            # Schedule next change
            Timer(INTERVAL, change_wallpaper).start()

        if __name__ == "__main__":
            change_wallpaper()
      '';
    };

    home.packages = with pkgs; [
      swww
      python3
    ];

    wayland.windowManager.hyprland.extraConfig = ''
      exec-once = ${config.home.homeDirectory}/.local/bin/wallpaper-changer.py > /tmp/wallpaper-changer.log 2>&1
    '';
  };
}
