{
  config,
  lib,
  namespace,
  ...
}:
let
  hostname = "bootstrap-testvm";
  cfg = config.${namespace}.impermanence;
in
{
  config = lib.mkIf (config.networking.hostName == hostname) (lib.mkMerge [
    {
      sops.age.sshKeyPaths = lib.mkIf (config.${namespace}.tools.sops.enable) [
        "/persist/system/etc/ssh/ssh_host_ed25519_key"
      ];
      environment.persistence."/persist/system" = {
        hideMounts = true;
        directories = [
          "/var/lib/nixos" # NixOS state data including user/group mappings
          "/var/lib/systemd/coredump" # System crash dumps for debugging
        ];
        files = [
          "/etc/machine-id" # Unique system identifier used by systemd and applications
          "/etc/ssh/ssh_host_ed25519_key" # SSH host keys
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key" # RSA keys as fallback
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      };
    }

    # The actual tmpfs root, active only once impermanence is enabled for the
    # host. Until then the system keeps booting from the btrfs root subvolume.
    (lib.mkIf cfg.enable {
      fileSystems."/" = lib.mkForce {
        device = "none";
        fsType = "tmpfs";
        options = [
          "defaults"
          "size=50%"
          "mode=755"
        ];
      };

      # /etc/shadow lives in tmpfs now; passwords must come from sops
      # (users_dima_hashed_password) instead of imperative passwd.
      users.mutableUsers = lib.mkForce false;
    })
  ]);
}
