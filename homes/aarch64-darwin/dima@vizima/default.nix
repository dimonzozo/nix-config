{ pkgs, inputs, ... }:
{
  home.packages =
    let
      unstable = import inputs.unstable {
        system = pkgs.system;
        config.allowUnfree = true;
      };
    in
    with pkgs;
    [
      age
      age-plugin-yubikey
      oath-toolkit
      openssh
      passage
      yubikey-manager
    ];

  # programs = {
  #   ssh = {
  #     enable = true;
  #     package = pkgs.openssh;
  #     enableDefaultConfig = false;
  #   };
  # };

  services = {
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

    ssh-agent = {
      enable = true;
    };
  };

  internal = {
    user = {
      enable = true;
      name = "dima";
      fullName = "Dmitrii Miaskovskii";
      email = "dmitry@enapter.com";
    };

    cli-apps = {
      fish = {
        enable = true;

        manageSshConfig = true;
        atuinSync = true;
        includeSecretAliases = true;
      };
      helix.enable = true;
      tmux.enable = true;
      home-manager.enable = true;
    };

    desktop = {
      macos.enable = true;
      # firefox.enable = true;
    };

    tools = {
      git.enable = true;
      common = {
        enable = true;
        core = {
          enable = true;
        };
        development = {
          enable = true;
          go = true;
          nix = true;
          markdown = true;
        };
      };
      sops.enable = true;
      kitty = {
        enable = true;
        macOStabsKeybindings = true;
        fontSize = 16;
        scrollbackLines = 10000;
      };
    };
  };

  home.sessionPath = [ "$HOME/bin" ];

  home.stateVersion = "25.05";
}
