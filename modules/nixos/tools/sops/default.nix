{
  config,
  lib,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.tools.sops;
in
{
  options.${namespace}.tools.sops = with types; {
    enable = mkBoolOpt false "Whether or not to enable sops-nix.";
  };

  config = mkIf cfg.enable {
    sops = {
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
      defaultSopsFile = ../../secrets/hosts/secrets.yaml;

      secrets.users_dima_hashed_password.neededForUsers = true;

      secrets.restic_passphrase = { };
      secrets.restic_environment = { };
      secrets.restic_repository = { };
      secrets.hurricane_credentials = { };
      secrets.vaultwarden_environment = { };
    };
  };
}
