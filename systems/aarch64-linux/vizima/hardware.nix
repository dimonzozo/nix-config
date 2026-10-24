{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "usbhid"
        "usb_storage"
        "sdhci_pci"
      ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices."enc" = {
        device = "/dev/disk/by-uuid/dd120da3-9dd9-4b51-8f58-14da462253f4";
        preLVM = true;
      };

      # Passwordless emergency shell in stage 1 (systemd initrd is already
      # enabled). Safety net for the impermanence migration; physical access
      # only, remove once the setup is stable.
      systemd.emergencyAccess = true;
    };
    loader = {
      timeout = 1;
      efi.canTouchEfiVariables = false;

      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        # Allow editing the kernel command line at the boot menu (e.g. to add
        # rd.systemd.unit=emergency.target). Kept on while impermanence is
        # being set up.
        editor = true;
      };
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = lib.mkForce false;
    };
    asahi = {
      enable = true;
      # Peripheral firmware is read from the default /boot/asahi at build time
      # (extracted by the Asahi installer). It is Apple-proprietary and must not
      # be committed here.
      # GPU acceleration needs no options since mesa 25.1: the mainline Asahi
      # driver is on by default (useExperimentalGPUDriver /
      # experimentalGPUInstallMode were removed upstream and now fail eval).
      setupAsahiSound = true;
      # peripheralFirmwareDirectory = "";
    };
  };

  networking = {
    useDHCP = false;
    networkmanager.enable = false;

    wireless = {
      enable = false;

      iwd = {
        enable = true;

        settings = {
          General = {
            EnableNetworkConfiguration = false; # systemd-networkd handles IP config
          };
          Network = {
            EnableIPv6 = false;
            RoutePriorityOffset = 300;
          };
          Settings = {
            AutoConnect = true;
          };
          Scan = {
            DisableRoamingScan = false;
          };
          DriverQuirks.UseDefaultInterface = true;
        };
      };
    };
  };

  # The wlan .network units live in nix-private (nixosModules.wlan-network,
  # imported from default.nix), as does the badwolf tunnel (badwolf-vpn).
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };

  # Default DNS over TLS with DNSSEC. No global ~. routing domain: per-link
  # routing in nix-private decides what goes elsewhere (the home zones to the
  # LAN DNS on home WiFi, everything through the VPN while it is up); the
  # global servers answer whatever no link claims.
  services.resolved = {
    enable = true;

    settings.Resolve = {
      DNS = "1.1.1.1#one.one.one.one 9.9.9.9#dns.quad9.net 2606:4700:4700::1111#one.one.one.one 2620:fe::fe#dns.quad9.net";
      DNSOverTLS = true;
      DNSSEC = true;
      Domains = [ "~." ];
    };
  };

  # Declarative description of the manually-created layout inside the
  # Asahi-allocated partition: LUKS on nvme0n1p5 -> vg0 -> swap + btrfs
  # subvolumes. partition mode never touches the Apple partitions or the
  # Asahi ESP (p4, mounted below). manageMounts stays off until the
  # disko-generated fileSystems tree is compared against the hand-written
  # one below; formatting via disko is a reinstall-only operation.
  internal.disko.laptop = {
    enable = true;
    mode = "partition";
    device = "/dev/disk/by-uuid/dd120da3-9dd9-4b51-8f58-14da462253f4";
    espDevice = "/dev/disk/by-uuid/E1C8-1925";
    swapSize = "32G";
    manageMounts = false;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cada7765-c2b1-4a59-a82d-753ed7b6ff8d";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/cada7765-c2b1-4a59-a82d-753ed7b6ff8d";
    fsType = "btrfs";
    options = [ "subvol=log" ];
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/cada7765-c2b1-4a59-a82d-753ed7b6ff8d";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/cada7765-c2b1-4a59-a82d-753ed7b6ff8d";
    fsType = "btrfs";
    options = [ "subvol=persist" ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/cada7765-c2b1-4a59-a82d-753ed7b6ff8d";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E1C8-1925";
    fsType = "vfat";
    options = [
      "umask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/751bb8a0-b4b1-4c06-8810-6c72d44f18b9"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
