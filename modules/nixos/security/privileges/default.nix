{
  config,
  lib,
  internal,
  namespace,
  pkgs,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.security.privileges;
in
{
  options.${namespace}.security.privileges = {
    enable = mkBoolOpt false "Whether or not to configure elevated privileges";
    backend = mkOption {
      type = types.enum [
        "sudo"
        "doas"
      ];
      default = "sudo";
      description = "Choose between sudo or doas as the privilege elevation tool";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages =
        if cfg.backend == "doas" then [ (pkgs.writeScriptBin "sudo" ''exec doas "$@"'') ] else [ ];
    }

    (mkIf (cfg.backend == "sudo") {
      security.sudo = {
        enable = true;
        extraRules = [
          {
            users = [ config.${namespace}.user.name ];
            commands = [
              {
                command = "ALL";
                options = [
                  "NOPASSWD"
                  "SETENV"
                ];
              }
            ];
          }
        ];
      };
      security.doas.enable = false;
    })

    (mkIf (cfg.backend == "doas") {
      security.sudo.enable = false;
      security.doas = {
        enable = true;
        extraRules = [
          {
            users = [ config.${namespace}.user.name ];
            noPass = true;
            keepEnv = true;
          }
        ];
      };
    })
  ]);
}
