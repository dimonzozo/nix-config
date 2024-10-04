{
  lib,
  config,
  pkgs,
  namespace,
  inputs,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.user;

  is-darwin = pkgs.stdenv.isDarwin;

  home-directory =
    if cfg.name == null then
      null
    else if is-darwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";
in
{

  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  options.${namespace}.user = {
    enable = mkOpt types.bool true "Whether to configure the user account.";
    name = mkOpt (types.nullOr types.str) null "The user account.";

    fullName = mkOpt types.str "" "The full name of the user.";
    email = mkOpt types.str "" "The email of the user.";

    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.name != null;
        message = "internal.user.name must be set";
      }
      {
        assertion = cfg.home != null;
        message = "internal.user.home must be set";
      }
    ];

    home = {
      username = cfg.name;
      homeDirectory = cfg.home;
    };
  };
}
