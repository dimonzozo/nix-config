{
  config,
  lib,
  namespace,
  ...
}:
let
  hostname = "lyria";
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
        "/var/lib/vaultwarden" # Vaultwarden server state
        "/var/lib/microvms" # MicroVMs state
        {
          directory = "/var/lib/zigbee2mqtt";
          user = "zigbee2mqtt";
          group = "zigbee2mqtt";
        } # Zigbee2mqtt state
        {
          directory = "/var/lib/jellyfin";
          user = "jellyfin";
          group = "jellyfin";
        } # Jellyfin database
        {
          directory = "/var/cache/jellyfin";
          user = "jellyfin";
          group = "jellyfin";
        } # Jellyfin cache
        {
          directory = "/var/lib/mosquitto";
          user = "mosquitto";
          group = "mosquitto";
        } # Mosquitto MQTT broker state
        {
          directory = "/var/lib/acme";
          user = "acme";
          group = "acme";
        } # ACME state
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
