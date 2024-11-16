{ ... }:
{
  internal = {
    user = {
      enable = true;
      name = "dmyaskovskiy";
      fullName = "Dmitrii Miaskovskii";
      email = "dmitry@enapter.com";
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
      tmux.enable = true;
      neovim.enable = true;
      home-manager.enable = true;
    };

    desktop.macos.enable = true;

    tools = {
      git.enable = true;
      common.enable = true;
      alacritty.enable = true;
      sops.enable = true;
    };
  };

  home.sessionPath = [ "$HOME/bin" ];

  home.stateVersion = "24.11";
}
