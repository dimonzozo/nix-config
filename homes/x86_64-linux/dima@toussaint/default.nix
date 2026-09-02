{ ... }:
{
  services = {
    ssh-agent = {
      enable = true;
    };
    syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";
      overrideDevices = false;
      overrideFolders = false;
      settings = {
        options.relaysEnabled = false;
        options.urAccepted = -1;
      };
    };
  };

  internal = {
    user = {
      enable = true;
      name = "dima";
      fullName = "Dmitrii Miaskovskii";
      email = "dimonzozo@gmail.com";
    };

    desktop = {
      mpv.enable = true;
      # iwgtk.enable = true;
      # hyprland.enable = true;
    };

    cli-apps = {
      fish = {
        enable = true;
        manageSshConfig = true;
        atuinSync = true;
        includeSecretAliases = true;
      };
      helix = {
        enable = true;
        # package = pkgs.internal.helix-steel;
      };
      home-manager.enable = true;
      lazygit.enable = true;
      default-editor.editor = "hx";
    };

    tools = {
      common = {
        enable = true;
        development = {
          enable = true;
          go = true;
          nix = true;
          markdown = true;
          sdr = true;
        };
        system = {
          enable = true;
          network = true;
        };
      };
      git.enable = true;

      kitty = {
        enable = true;
        tabsKeybindings = true;
        linuxCopyPasteBindings = true;
        scrollbackLines = 10000;
      };

      sops.enable = true;
    };
  };
}
