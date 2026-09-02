{
  lib,
  namespace,
  internal,
  pkgs,
  ...
}:
with internal;
{
  imports = [ ./hardware.nix ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGenb+fvIvqiA3n/rT2kzKcax8VauszpafEDyNADtY7/"
  ];

  services.getty.autologinUser = "dima";

  internal = {
    impermanence.enable = true;

    nix.enable = true;

    security = {
      privileges.enable = true;
      tpm2.enable = true;
    };

    system = {
      locale.enable = true;
      time.enable = true;
    };

    tools = {
      git.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    at
    firefox
  ];

  system.stateVersion = "24.11";
}
