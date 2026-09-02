{
  config,
  lib,
  namespace,
  ...
}:
let
  hostname = "lyria-testvm";
in
{
  config = lib.mkIf (config.networking.hostName == hostname) {
    sops.age.sshKeyPaths = lib.mkIf (config.${namespace}.tools.sops.enable) [
      "/persist/system/etc/ssh/ssh_host_ed25519_key"
    ];
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos" # NixOS state data including user/group mappings
        "/var/lib/systemd/coredump" # System crash dumps for debugging
        "/var/lib/upower" # Battery statistics and history
        "/var/lib/libvirt" # VMs state
        "/var/lib/docker" # Docker state
        "/var/lib/zigbee2mqtt" # Zigbee2mqtt state
        "/var/lib/jellyfin" # Jellyfin state
        "/var/lib/mosquitto" # Mosquitto MQTT broker state
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
