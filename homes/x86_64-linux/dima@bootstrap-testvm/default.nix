{ ... }:
{
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
      git.enable = true;
    };

    # Stage 2 of the bootstrap flow, together with the system-level flags:
    # tools.sops.enable = true;
  };
}
