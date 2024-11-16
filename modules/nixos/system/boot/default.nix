{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.boot;
in
{
  options.${namespace}.system.boot = with types; {
    enable = mkBoolOpt false "Whether or not to enable booting.";
  };

  config = mkIf cfg.enable {
    boot.loader.timeout = 1;
    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
    boot.loader.systemd-boot.configurationLimit = 30;
    boot.loader.efi.canTouchEfiVariables = true;

    # https://github.com/NixOS/nixpkgs/blob/c32c39d6f3b1fe6514598fa40ad2cf9ce22c3fb7/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix#L66
    boot.loader.systemd-boot.editor = false;

    environment.systemPackages = with pkgs; [ efibootmgr ];
  };
}
