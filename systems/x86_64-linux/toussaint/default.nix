{ lib, namespace, ... }:
with lib;
with lib.${namespace};
{
  imports = [ ./hardware.nix ];

  internal = {
    suites = {
      common = enabled;
      desktop = enabled;
    };
  };

  specialisation = {
    gnome.configuration = {
      internal.desktop.hyprland = disabled;
      internal.desktop.gnome = enabled;
    };
  };

  system.stateVersion = "24.11";
}
