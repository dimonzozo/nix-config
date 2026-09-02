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
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
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

    # hardware = {
    #   audio.enable = true;
    # };

    security = {
      gpg.enable = true;
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = false;
  };

  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    at
    bingrep # Binary pattern matching tool for searching through executable files and libraries
    bintools # Collection of binary utilities including objdump, nm, readelf for binary analysis
    claude-code # Anthropic's command-line tool for AI-assisted coding and development tasks
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
    openssl # Cryptographic toolkit providing SSL/TLS implementation and certificate management utilities
    radare2 # Comprehensive reverse engineering framework with disassembler, debugger, and binary analysis tools
    socat
    teams-for-linux
    telegram-desktop
    tz # Timezone utility for displaying time across multiple zones with formatting options
    xxd # Hex dump utility for creating and reversing hexadecimal representations of binary data
    zed-editor
  ];

  system.stateVersion = "25.05";

  nixpkgs.config = {
    allowUnfree = true;
    # allowUnsupportedSystem = true;
  };
}
