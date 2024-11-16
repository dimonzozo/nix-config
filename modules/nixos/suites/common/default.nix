{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.common;
in
{
  options.${namespace}.suites.common = with types; {
    enable = mkBoolOpt false "Whether or not to enable common configuration.";
  };

  config = mkIf cfg.enable {
    internal = {
      nix = enabled;

      # cli-apps = {
      #   neovim = enabled;
      # };

      tools = {
        at = enabled;
        git = enabled;
        llm = enabled;
      };

      hardware = {
        audio = enabled;
        fingerprint = enabled;
        networking = enabled;
      };

      services = {
        printing = enabled;
      };

      security = {
        doas = enabled;
        gpg = enabled;
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
