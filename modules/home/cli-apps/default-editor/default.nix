{
  lib,
  config,
  namespace,
  internal,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.cli-apps.default-editor;
in
{
  options.${namespace}.cli-apps.default-editor = with types; {
    editor = mkOpt str "hx" "Default editor.";
  };

  config = {
    home = {
      sessionVariables = {
        EDITOR = cfg.editor;
      };
    };
  };
}
