{
  config,
  inputs,
  internal,
  lib,
  namespace,
  ...
}:
with internal;
{
  imports = [
    ./hardware.nix
    inputs.microvm.nixosModules.host
    inputs.nix-private.nixosModules.acme
    inputs.nix-private.nixosModules.lyria-network
    # inputs.nix-private.nixosModules.mvm-gateway
    inputs.nix-private.nixosModules.smart-home
    # inputs.nix-private.nixosModules.vault
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFFIqjtY8HnTMfjLe+2RIANR+i/JieYM0N/QcyFzOe4yAAAADHNzaDpwZXJzb25hbA== yubikey-nano"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFZVp2MqbrAW2MNiY0G73xxY5g3EOn/MDKYRpgKL87AyAAAADHNzaDpwZXJzb25hbA== yubikey-nfc"
  ];

  microvm.host.enable = true;

  services = {
    openssh = {
      enable = true;

      settings = {
        AllowAgentForwarding = true;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    restic.backups = {
      remote =
        let
          user = config.${namespace}.user.name;
        in
        {
          initialize = true;
          exclude = [
            "/persist/system/var/cache"
            "/persist/system/var/lib/docker"
          ];
          paths = [
            "/home/${user}/sync"
            "/persist/system"
          ];
          progressFps = 0.1;
          checkOpts = [ "--with-cache" ];
          extraBackupArgs = [ ];
          extraOptions = [ ];
          passwordFile = config.sops.secrets.restic_passphrase.path;
          environmentFile = config.sops.secrets.restic_environment.path;
          repositoryFile = config.sops.secrets.restic_repository.path;
          timerConfig = { };
        };
    };
  };

  # this settings will break Docker networking
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-ip6tables" = 0;
  };

  networking = {
    nftables = {
      enable = true;
      flushRuleset = true;
    };

    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        # VNC displays :50-:59 exposed by custom VMs and test setups
        {
          from = 5950;
          to = 5959;
        }
      ];
    };
  };

  users.users.${config.services.jellyfin.user}.extraGroups = [
    "video"
    "render"
  ];

  internal = {
    impermanence.enable = true;

    virtualization = {
      enable = true;
      libvirt.enable = true;
    };

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
      sops.enable = true;
    };
  };

  # programs.nix-ld.enable = true;

  system.stateVersion = "25.11";
}
