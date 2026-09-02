{ ... }:
{
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
      default-editor.editor = "hx";
    };

    desktop.macos.enable = true;

    tools = {
      git.enable = true;
      common.enable = true;
      sops.enable = true;
    };
  };

  home.sessionPath = [ "$HOME/bin" ];

  home.stateVersion = "24.11";
}
