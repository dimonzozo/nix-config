{
  ...
}:
{
  internal = {
    user = {
      enable = true;
      name = "dima";
      fullName = "Dmitrii Miaskovskii";
      email = "dimonzozo@gmail.com";
    };

    desktop = {
      mpv.enable = true;
      theme.enable = true;
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
      default-editor.editor = "hx";
    };

    tools = {
      common = {
        enable = true;
        # development = {
        #   enable = true;
        #   go = true;
        #   nix = true;
        #   markdown = true;
        #   sdr = true;
        # };
      };
      git.enable = true;

      kitty = {
        enable = true;
        tabsKeybindings = true;
        scrollbackLines = 10000;
      };

      sops.enable = true;
    };
  };
}
