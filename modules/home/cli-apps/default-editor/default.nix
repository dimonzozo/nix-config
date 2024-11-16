{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli-apps.default-editor;
in
{
  options.${namespace}.cli-apps.default-editor = with types; {
    editor = mkOpt str "nvim" "Default editor.";
  };

  config = {
    home = {
      sessionVariables = {
        EDITOR = cfg.editor;
      };
    };
  };
}
