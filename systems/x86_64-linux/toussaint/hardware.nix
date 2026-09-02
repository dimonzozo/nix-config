{
  inputs,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  boot = {
    binfmt.emulatedSystems = [
      "aarch64-linux"
      "armv7l-linux"
    ];

    loader = {
      timeout = 1;

      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
        extraEntries = ''
          menuentry "FreeBSD" {
            chainloader /EFI/freebsd/loader.efi
          }

          menuentry "OpenBSD" {
            chainloader /EFI/openbsd/bootx64.efi
          }

          menuentry 'UEFI Firmware Settings' {
            fwsetup
          }
        '';
        gfxmodeEfi = "1024x768x32";
      };
    };

    kernelModules = [
      "kvm-amd"
      "amdgpu"
    ];

    kernelParams = [
      # "initcall_blacklist=acpi_cpufreq_init"
      # "mem_sleep_default=s2idle"
      # "nomodeset"
      # "quiet"
      # "amdgpu.dcdebugmask=0x12"
      # "console=tty0"
      # "console=ttyS0,115200n8"
      # "amdgpu.ppfeaturemask=0xfff7ffff"
    ];

    extraModprobeConfig = ''
      options mt7921e disable_aspm=1
    '';

    # Plymouth configuration
    # plymouth = {
    #   enable = true;
    #   # theme = "spinner";
    #   theme = "breeze";
    # };

    # Optional: Configure kernel message logging
    # kernel.sysctl = {
    #   "kernel.printk" = "7 4 1 7"; # console_loglevel default_message_loglevel minimum_console_loglevel default_console_loglevel
    # };
    # consoleLogLevel = 7;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
        "tpm"
        "tpm_tis"
        "tpm_crb"
        "k10temp"
      ];
      kernelModules = [
        "dm-snapshot"
        "tpm"
        "tpm_tis" # For discrete TPM
        "tpm_crb" # For firmware TPM
      ];
      systemd.enable = true; # Required for TPM2 handling

      # NOTE: enabling this is a safety risk, but it is good for debug
      # systemd.emergencyAccess = true;

      luks.devices."enc" = {
        device = "/dev/disk/by-uuid/6da23928-95a2-45e3-a72b-d4d2c09a2f3d";
        preLVM = true;
        crypttabExtraOpts = [
          "tpm2-device=auto"
          "tpm2-pcrs=7"
          "tpm2-pin=yes"
          "fallback=yes" # Allow fallback to LUKS passphrase
        ];
      };

      systemd.services.btrfs-cleanup = {
        description = "BTRFS root cleanup and snapshot management";
        wantedBy = [ "initrd.target" ];
        after = [ "systemd-hibernate-resume.service" ];
        before = [ "sysroot.mount" ];
        unitConfig = {
          DefaultDependencies = false;
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          set -euo pipefail

          MOUNT_POINT="/btrfs_tmp"
          SNAPSHOT_DIR="root_snapshots"
          MAX_SNAPSHOTS=30
          BTRFS_DEVICE="/dev/mapper/pool-root"

          # Mount btrfs root
          mkdir -p "$MOUNT_POINT"
          mount -o subvol=/ "$BTRFS_DEVICE" "$MOUNT_POINT"

          # Create snapshots directory if doesn't exist
          if [[ ! -d "$MOUNT_POINT/$SNAPSHOT_DIR" ]]; then
              btrfs subvolume create "$MOUNT_POINT/$SNAPSHOT_DIR"
          fi

          # Create read-only snapshot of current root
          timestamp=$(date "+%Y-%m-%d_%H:%M:%S")
          btrfs subvolume snapshot -r "$MOUNT_POINT/root" "$MOUNT_POINT/$SNAPSHOT_DIR/root_$timestamp"

          # Delete older snapshots
          find "$MOUNT_POINT/$SNAPSHOT_DIR" -maxdepth 1 -type d -mtime +30 | while read -r snapshot; do
              if [[ "$snapshot" != "$MOUNT_POINT/$SNAPSHOT_DIR" ]]; then
                  btrfs subvolume delete "$snapshot"
              fi
          done

          # Delete nested subvolumes in root
          btrfs subvolume list -o "$MOUNT_POINT/root" | cut -f9 -d' ' | while read -r subvol; do
              btrfs subvolume delete "$MOUNT_POINT/$subvol"
          done

          # Delete and recreate root
          btrfs subvolume delete "$MOUNT_POINT/root"
          btrfs subvolume create "$MOUNT_POINT/root"

          umount "$MOUNT_POINT"
        '';
      };
    };

    extraModulePackages = [ ];

    kernelPackages = pkgs.linuxPackages_6_12;
    # kernelPackages = pkgs.linuxPackagesFor (
    #   pkgs.linux_6_6.override {
    #     argsOverride = rec {
    #       src = pkgs.fetchurl {
    #         url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
    #         sha256 = "sha256-iVflwtrNvEehbb8fYwPKcIhAm+YZejiB91IxMnU1esY=";
    #       };
    #       version = "6.6.87";
    #       modDirVersion = "6.6.87";
    #     };
    #   }
    # );

    resumeDevice = "/dev/disk/by-uuid/a9062f39-5c61-4d91-8eb7-9550b6ed9962";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "noatime"
      "nodatacow"
    ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/5dd6977f-6b91-45b6-b87e-135aac448639";
    fsType = "btrfs";
    options = [
      "subvol=log"
      "nodatacow"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/AD3D-8FF1";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/a9062f39-5c61-4d91-8eb7-9550b6ed9962"; } ];

  # internal.user.extraGroups = [ "networkmanager" ];

  networking = {
    useDHCP = false;

    firewall = {
      checkReversePath = false;
      allowedUDPPorts = [ 51820 ]; # WireGuard default
    };

    wireless = {
      # enable = true;
      enable = false;
      iwd = {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = false; # Let systemd-networkd handle IP config
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

    networkmanager.enable = false;
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };

  # services.openvpn.servers = {
  #   work = {
  #     config = ''
  #       config /home/dima/vpn/work.ovpn
  #       auth-retry interact
  #       script-security 2
  #       up ${pkgs.internal.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
  #       down ${pkgs.internal.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
  #       down-pre
  #     '';
  #     autoStart = false;
  #   };
  # };

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  # Enable systemd-resolved for DNS encryption and split DNS
  services.resolved = {
    enable = true;

    settings.Resolve = {
      DNS = "1.1.1.1#one.one.one.one 9.9.9.9#dns.quad9.net 2606:4700:4700::1111#one.one.one.one 2620:fe::fe#dns.quad9.net";
      DNSOverTLS = true;
      DNSSEC = true;
      Domains = [ "~." ];
    };

    # extraConfig = ''
    #   DNS=1.1.1.1#one.one.one.one 9.9.9.9#dns.quad9.net 2606:4700:4700::1111#one.one.one.one 2620:fe::fe#dns.quad9.net
    #   FallbackDNS=8.8.8.8#dns.google 1.0.0.1#one.one.one.one 2001:4860:4860::8888#dns.google 2606:4700:4700::1001#one.one.one.one

    #   # DNS=1.1.1.1#one.one.one.one 9.9.9.9#dns.quad9.net
    #   # FallbackDNS=8.8.8.8#dns.google 1.0.0.1#one.one.one.one

    #   Domains=~.
    #   DNSOverTLS=yes
    #   DNSSEC=true
    #   Cache=yes
    #   DNSStubListener=yes
    #   # LLMNR=yes
    #   MulticastDNS=yes
    #   ReadEtcHosts=yes

    #   # Additional privacy settings
    #   CacheFromLocalhost=no
    # '';
  };

  # Fixes an issue that normally causes nixos-rebuild to fail.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    # framework.laptop13.audioEnhancement.enable = true;

    enableRedistributableFirmware = true;
    firmware = [ pkgs.linux-firmware ];

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    cpu.amd.updateMicrocode = true;
    graphics = {
      enable = true;

      extraPackages = with pkgs; [
        mesa
        libdrm
        libva
        libva-utils
        libva-vdpau-driver

        # vulkan
        vulkan-loader
        vulkan-validation-layers

        # For Firefox's multimedia backend
        libvdpau
        libvdpau-va-gl

        # rocm-opencl-icd
        # rocm-opencl-runtime
        # rocm-opencl-icd # ROCm OpenCL ICD (Installable Client Driver) loader
        # rocm-opencl-runtime # ROCm OpenCL runtime environment
        # intel-media-driver # Intel VA-API media driver (iHD) for hardware video acceleration
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    libva-utils
    nvtopPackages.amd
    efibootmgr

    openvpn
    expect

    wireguard-tools
  ];

  services.udev = {
    extraHwdb = ''
      # Internal AT keyboard (Framework 13)
      evdev:atkbd:*
       KEYBOARD_KEY_3a=leftctrl
       KEYBOARD_KEY_db=leftalt
       KEYBOARD_KEY_38=leftmeta
    '';

    extraRules = ''
      KERNEL=="renderD128", GROUP="video", MODE="0660"
      KERNEL=="card0", GROUP="video", MODE="0660"

      # FTDI FT2232H (used in Digilent boards for JTAG)
      SUBSYSTEM=="tty", ENV{ID_VENDOR_ID}=="0403", ENV{ID_MODEL_ID}=="6010", MODE="0666"
      ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="0403", ENV{ID_MODEL_ID}=="6010", GROUP="users", MODE="0666"
    '';
  };

  services.fwupd.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.sessionVariables = {
    # vulkan
    # AMD_VULKAN_ICD = "RADV"; # Force RADV driver
    # RADV_DEBUG = "info"; # More verbose Vulkan logging
    # VK_LOADER_DEBUG = "info"; # Help diagnose driver loading issues
    # MESA_VK_VERSION_OVERRIDE = "1.3"; # Force Vulkan 1.3 features
    # LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    # VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    LIBVA_DRIVER_NAME = "radeonsi";
    EGL_PLATFORM = "wayland";
    WLR_DRM_NO_ATOMIC = "1";
  };

  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandlePowerKey = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };
}
