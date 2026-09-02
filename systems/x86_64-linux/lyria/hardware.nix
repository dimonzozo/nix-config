{
  inputs,
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.disko.nixosModules.disko
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "uas"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_6_12;
    extraModulePackages = [ ];
    loader = {
      timeout = 1;
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 30;
        # https://github.com/NixOS/nixpkgs/blob/c32c39d6f3b1fe6514598fa40ad2cf9ce22c3fb7/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix#L59
        editor = false;
      };

    };
    swraid.enable = true;
  };

  # Interface, VLAN and address layout lives in the private flake:
  # inputs.nix-private.nixosModules.lyria-network (imported from default.nix).
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };

  networking.useDHCP = false;
  networking.useNetworkd = true;

  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };

      nvme1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot2";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
    };

    mdadm.root = {
      type = "mdadm";
      level = 1;
      metadata = "1.2";
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "/home" = {
            mountOptions = [ "compress=zstd" ];
            mountpoint = "/home";
          };
          "/nix" = {
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
            mountpoint = "/nix";
          };
          "/persist" = {
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
            mountpoint = "/persist";
          };
          "/log" = {
            mountOptions = [
              "nodatacow"
              "noatime"
            ];
            mountpoint = "/var/log";
          };
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/external 0755 root root"
  ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=25%"
      "mode=755"
    ];
  };
  fileSystems."/mnt/external" = {
    device = "/dev/disk/by-partuuid/e19d5735-91b1-e244-b4b0-83d4b8014866";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
      "x-systemd.device-timeout=10"
      "x-systemd.automount"
      "compress=zstd"
      "noatime"
      "space_cache=v2"
      "autodefrag"
    ];
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    jellyfin-ffmpeg
    libva-utils
    virtiofsd
  ];

  # Fixes an issue that normally causes nixos-rebuild to fail.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  systemd.services.ethtool-settings = {
    description = "Configure ethtool options";
    after = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.ethtool ];
    script = ''
      ethtool -K eno1 tso off gso off
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  services.smartd.enable = true;

  services.udev.extraRules = ''
    KERNEL=="renderD128", GROUP="video", MODE="0660"
    KERNEL=="card0", GROUP="video", MODE="0660"
  '';

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        # Intel's media driver for hardware video acceleration
        intel-media-driver
        # OpenCL runtime for Intel GPUs
        intel-compute-runtime
        # VA-API (Video Acceleration API) drivers
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };
}
