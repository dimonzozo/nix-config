{
  inputs,
  config,
  lib,
  internal,
  namespace,
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
    virtualization = {
      enable = true;

      qemu = {
        enable = true;
        users = [ config.${namespace}.user.name ];
      };

      docker.enable = true;

      libvirt = {
        enable = true;
      };
    };

    desktop = {
      plasma.enable = true;
      # niri.enable = true;
    };

    impermanence.enable = true;

    apps = {
      firefox.enable = true;
      steam.enable = true;
    };

    tools = {
      git.enable = true;
      sops.enable = true;
    };

    hardware = {
      audio.enable = true;
    };

    security = {
      # gpg.enable = true;
      keyring.enable = true;
      privileges.enable = true;
      tpm2.enable = true;
    };

    system = {
      locale.enable = true;
      time.enable = true;
      xkb.enable = true;
    };

    nix.enable = true;
  };

  # specialisation = {
  #   niri.configuration = {
  #     internal.desktop.plasma.enable = false;
  #     internal.desktop.niri.enable = true;
  #   };
  # };

  services = {
    # avahi = {
    #   enable = true;
    #   nssmdns4 = false;
    #   publish.enable = false;
    # };

    pcscd.enable = true;

    fprintd.enable = true;

    restic.backups = {
      remote =
        let
          user = config.${namespace}.user.name;
        in
        {
          initialize = true;
          exclude = [
            "/home/${user}/projects/openbsd-src"
            "/home/${user}/projects/nixpkgs"
            "/home/${user}/work/yocto/linux-kernel"
            "/home/${user}/Documents/sdr"
            "/persist/system/var/lib/libvirt"
            "/persist/system/var/lib/docker"
          ];
          paths = [
            "/home/${user}/Desktop"
            "/home/${user}/Documents"
            "/home/${user}/Music"
            "/home/${user}/Pictures"
            "/home/${user}/projects"
            "/home/${user}/vms"
            "/home/${user}/work"
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

  documentation.dev.enable = true;

  environment.systemPackages =
    let
      unstable = import inputs.unstable {
        system = pkgs.system;
        config.allowUnfree = true;
      };
    in
    with pkgs;
    [
      age
      age-plugin-yubikey
      at
      bingrep # Binary pattern matching tool for searching through executable files and libraries
      bintools # Collection of binary utilities including objdump, nm, readelf for binary analysis
      # bitwarden-desktop
      containerd
      darktable
      dijo # Terminal-based habit tracker with scriptable interface for productivity monitoring
      firecracker
      gimp
      hexyl # Modern hex viewer with syntax highlighting and improved readability for binary inspection
      irssi # Terminal-based IRC client for real-time chat and communication protocols
      iw
      jless # JSON viewer and navigator with search capabilities and structured data exploration
      liburing
      lnav # Advanced log file navigator with automatic format detection and analysis features
      mods
      nerdctl
      oath-toolkit
      openssl # Cryptographic toolkit providing SSL/TLS implementation and certificate management utilities
      passage
      radare2 # Comprehensive reverse engineering framework with disassembler, debugger, and binary analysis tools
      socat
      teams-for-linux
      telegram-desktop
      tz # Timezone utility for displaying time across multiple zones with formatting options
      xxd # Hex dump utility for creating and reversing hexadecimal representations of binary data
      zed-editor
    ];

  system.stateVersion = "24.11";
}
