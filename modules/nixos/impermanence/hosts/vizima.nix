{
  config,
  lib,
  namespace,
  ...
}:
let
  hostname = "vizima";
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
          "/etc/systemd/network" # systemd-networkd network configurations
          "/var/lib/iwd" # WiFi network profiles and credentials
          "/var/lib/bluetooth" # Bluetooth pairings and device information
          "/var/lib/cups" # Printer settings and configurations
          "/var/lib/fwupd" # Firmware update history and settings
          "/var/lib/nixos" # NixOS state data including user/group mappings
          "/var/lib/power-profiles-daemon" # Power management profiles
          # All of systemd's state: backlight, coredumps, timer stamps,
          # random-seed, and crucially credential.secret — the host key for
          # encrypted credentials (no TPM2 on Apple Silicon, and systemd
          # refuses to generate it on tmpfs). libvirtd's
          # LoadCredentialEncrypted depends on it.
          "/var/lib/systemd"
          "/var/lib/upower" # Battery statistics and history
          "/var/lib/libvirt" # VMs state
          "/var/lib/docker" # Docker state
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
          "size=25%"
          "mode=755"
        ];
      };

      # /etc/shadow lives in tmpfs now; passwords must come from sops
      # (users_dima_hashed_password) instead of imperative passwd.
      users.mutableUsers = lib.mkForce false;
    })
  ]);
}
