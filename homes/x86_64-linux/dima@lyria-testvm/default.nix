{ ... }:
{
  # Minimal home for the lyria test VM: no secrets, no sync.
  internal = {
    user = {
      enable = true;
      name = "dima";
      fullName = "Dmitrii Miaskovskii";
      email = "dimonzozo@gmail.com";
    };

    cli-apps = {
      fish.enable = true;
      helix.enable = true;
      home-manager.enable = true;
      default-editor.editor = "hx";
    };

    tools = {
      common.enable = true;
      git.enable = true;
    };
  };
}
