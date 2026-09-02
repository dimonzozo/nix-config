{
  options,
  config,
  lib,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.apps._1password;
in
{
  options.${namespace}.apps._1password = with types; {
    enable = mkBoolOpt false "1Password - password manager and secure digital wallet";
    enableGUI = mkBoolOpt true "Install 1password GUI.";
    enableCLI = mkBoolOpt false "Install 1password CLI.";
  };

  config = mkIf cfg.enable {
    programs = {
      _1password-gui = mkIf cfg.enableGUI {
        enable = true;
        polkitPolicyOwners = [ config.${namespace}.user.name ];
      };

      _1password = mkIf cfg.enableCLI {
        enable = true;
      };
    };
  };
}
