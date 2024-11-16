{ lib, namespace, ... }:
with lib.${namespace};
{
  internal = {
    user = {
      enable = true;
      name = "dima";
      fullName = "Dmitrii Miaskovskii";
      email = "dimonzozo@gmail.com";
    };

    desktop = {
      ags = enabled;
      freetube = enabled;
      hyprland = enabled;
      mpv = enabled;
      qutebrowser = enabled;
      theme = enabled;
      wallpapers-changer = enabled;
    };

    cli-apps = {
      fish = {
        enable = true;

        # TODO: add assert
        # requires tools.sops.enable == true;
        manageSshKeys = true;
        manageSshConfig = true;
        atuinSync = true;
        includeSecretAliases = true;
      };
      home-manager = enabled;
      lazygit = enabled;
      neovim = enabled;
      tmux = enabled;
    };

    tools = {
      bottom = enabled;
      common = enabled;
      git = enabled;
      kitty = enabled;
      sops = enabled;
    };
  };
}
