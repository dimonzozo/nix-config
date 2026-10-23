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

      # systemd = {
      #   # enable = true;
      #   # NOTE: enabling this is a safety risk, but it is good for debug
      #   # emergencyAccess = true;
      #   #
      #   # contents = {
      #   #   "/etc/machine-id".text = "";
      #   # };
      # };
    };
    loader = {
      timeout = 1;
      efi.canTouchEfiVariables = false;

      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        # https://github.com/NixOS/nixpkgs/blob/c32c39d6f3b1fe6514598fa40ad2cf9ce22c3fb7/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix#L59
        editor = false;
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
      # useExperimentalGPUDriver = true;
      setupAsahiSound = true;
      # experimentalGPUInstallMode = "overlay";
      # peripheralFirmwareDirectory = "";
    };
  };

  networking = {
    # useDHCP = false;
    # dhcpcd.enable = false;
    useNetworkd = true;
    networkmanager.enable = false;

    wireless = {
      enable = false;

      iwd = {
        enable = true;

        settings = {
          General = {
            # EnableNetworkConfiguration = false; # Let systemd-networkd handle IP config
            EnableNetworkConfiguration = true;
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

  # systemd.network = {
  #   enable = true;
  #   networks."20-wlan" = {
  #     matchConfig.Name = "wlan0";
  #     networkConfig = {
  #       DHCP = "yes";
  #       IPv6AcceptRA = true;
  #       MulticastDNS = true;
  #     };
  #     dhcpV4Config.RouteMetric = 600; # ethernet, if you ever plug one in, wins at 100
  #     linkConfig.RequiredForOnline = "routable";
  #   };
  #   wait-online.enable = false;
  # };

  services.resolved = {
    enable = true;

    settings.Resolve = {
      DNS = "1.1.1.1#one.one.one.one 9.9.9.9#dns.quad9.net 2606:4700:4700::1111#one.one.one.one 2620:fe::fe#dns.quad9.net";
      DNSOverTLS = true;
      DNSSEC = true;
      Domains = [ "~." ];
    };
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
