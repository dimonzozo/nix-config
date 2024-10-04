{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.user;
in
{
  options.${namespace}.user = {
    name = mkOpt types.str "" "The user account.";
    fullName = mkOpt types.str "" "The full name of the user.";
    email = mkOpt types.str "" "The email of the user.";
    uid = mkOpt (types.nullOr types.int) 501 "The uid for the user account.";
  };

  config = {
    users.knownUsers = [ cfg.name ];
    users.users.${cfg.name} = {
      uid = mkIf (cfg.uid != null) cfg.uid;
      shell = pkgs.fish;
    };

    programs = {
      fish = {
        enable = true;
        shellAliases = {
          vi = "nvim";
          vim = "nvim";
        };
      };
    };

    environment = {
      shells = [ pkgs.fish ];
    };
  };
}
