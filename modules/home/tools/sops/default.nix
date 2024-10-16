{
  config,
  lib,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.tools.sops;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.${namespace}.tools.sops = with types; {
    enable = mkBoolOpt false "Whether or not to install sops tool.";
  };

  config = mkIf cfg.enable {
    sops = {
      age = {
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        generateKey = false;
      };
      defaultSopsFile = ../../../../secrets/secrets.yaml;
    };
  };
}
