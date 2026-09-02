{
  config,
  lib,
  namespace,
  ...
}:
let
  hostname = "toussaint";
in
{
  config = lib.mkIf (config.networking.hostName == hostname) {
    sops.age.sshKeyPaths = lib.mkIf (config.${namespace}.tools.sops.enable) [
      "/persist/system/etc/ssh/ssh_host_ed25519_key"
    ];
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections" # WiFi and network configurations
        "/etc/systemd/network" # systemd-networkd network configurations
        "/var/lib/iwd" # WiFi network profiles and credentials
        "/var/lib/bluetooth" # Bluetooth pairings and device information
        "/var/lib/cups" # Printer settings and configurations
        "/var/lib/fprint" # Fingerprint reader data if you use one
        "/var/lib/fwupd" # Firmware update history and settings
        "/var/lib/NetworkManager" # Network Manager state files
        "/var/lib/nixos" # NixOS state data including user/group mappings
        "/var/lib/power-profiles-daemon" # Power management profiles
        "/var/lib/systemd/backlight" # Screen brightness settings
        "/var/lib/systemd/coredump" # System crash dumps for debugging
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
  };
}
