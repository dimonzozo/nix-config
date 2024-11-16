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
  cfg = config.${namespace}.security.tpm2;
in
{
  options.${namespace}.security.tpm2 = {
    enable = mkBoolOpt false "Enable TPM2 support.";
  };

  config = mkIf cfg.enable {
    # Enable base TPM2 support
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true; # Enable PKCS#11 support
      tctiEnvironment = {
        enable = true;
        interface = "device";
      };
    };

    internal = {
      user.extraGroups = [ "tss" ];
    };

    environment.systemPackages = with pkgs; [
      tpm2-tools
      tpm2-tss
      ent
    ];
  };
}
