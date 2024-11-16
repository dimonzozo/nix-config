{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.common-slim;
in
{
  options.${namespace}.suites.common-slim = with types; {
    enable = mkBoolOpt false "Whether or not to enable common-slim configuration.";
  };

  config = mkIf cfg.enable {
    internal = {
      nix = enabled;

      hardware = {
        networking = enabled;
      };

      security = {
        doas = enabled;
        keyring = enabled;
        tpm2 = enabled;
      };

      system = {
        boot = enabled;
        locale = enabled;
        time = enabled;
        xkb = enabled;
      };
    };
  };
}
