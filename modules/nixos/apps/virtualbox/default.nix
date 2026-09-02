{
  options,
  config,
  lib,
  internal,
  pkgs,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.apps.virtualbox;
in
{
  options.${namespace}.apps.virtualbox = with types; {
    enable = mkBoolOpt false "VirtualBox - x86 virtualization software for running multiple operating systems";
  };

  config = mkIf cfg.enable {
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

    internal.user.extraGroups = [ "vboxusers" ];
  };
}
