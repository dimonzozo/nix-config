{
  options,
  config,
  pkgs,
  lib,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.tools.go;
in
{
  options.${namespace}.tools.go = with types; {
    enable = mkBoolOpt false "Whether or not to enable Go support.";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        go
        gopls
      ];
      sessionVariables = {
        GOPATH = "$HOME/work/go";
      };
    };
  };
}
