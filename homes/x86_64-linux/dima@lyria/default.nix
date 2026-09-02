{
  lib,
  namespace,
  ...
}:
with lib.${namespace};
{
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    overrideDevices = false;
    overrideFolders = false;
    settings = {
      options.relaysEnabled = false;
      options.urAccepted = -1;
    };
  };

  internal = {
    user = {
      enable = true;
      name = "dima";
      fullName = "Dmitrii Miaskovskii";
      email = "dimonzozo@gmail.com";
    };

    cli-apps = {
      fish = {
        enable = true;
        manageSshConfig = true;
        atuinSync = true;
        includeSecretAliases = true;
      };
      helix.enable = true;
      home-manager.enable = true;
      lazygit.enable = true;
      zellij.enable = true;
      default-editor.editor = "hx";
    };

    tools = {
      common.enable = true;
      git.enable = true;
      sops.enable = true;
    };
  };
}
