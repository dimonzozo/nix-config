{
  config,
  lib,
  internal,
  namespace,
  inputs,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.tools.sops;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  options.${namespace}.tools.sops = with types; {
    enable = mkBoolOpt false "SOPS - secrets management tool for encrypting configuration files";
  };

  config = mkIf cfg.enable {
    sops = {
      age = {
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        generateKey = true;
      };
      defaultSopsFile = ../../secrets/users/dima/secrets.yaml;
    };
  };
}
