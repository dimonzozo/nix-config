{
  lib,
  internal,
  pkgs,
  ...
}:
with lib;
with internal;
{
  imports = [
    ./hardware.nix
  ];

  internal = {
    desktop = {
      plasma.enable = true;
    };

    apps = {
      _1password.enable = true;
      firefox.enable = true;
    };

    tools = {
      git.enable = true;
    };

    security = {
      gpg.enable = true;
      keyring.enable = true;
      privileges.enable = true;
      tpm2.enable = true;
    };

    system = {
      locale = {
        enable = true;
        termFont = "ter-v16n";
      };

      time.enable = true;
      xkb.enable = true;
    };

    nix.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "prohibit-password";
    };
  };

  environment.systemPackages = with pkgs; [
    at
    telegram-desktop
  ];

  system.stateVersion = "24.11";
}
