{
  config,
  lib,
  inputs,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.disko.laptop;
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  # The standard layout for impermanent laptops:
  # LUKS -> LVM -> swap LV + btrfs LV with subvolumes root/home/nix/persist/log.
  # Matches what toussaint and vizima run today; subvol=root is only the
  # bootstrap-stage rootfs, the impermanence host file replaces / with tmpfs
  # once enabled.
  #
  # mode = "disk": device is a whole disk; disko creates GPT with an ESP and
  #   the LUKS partition, and mounts them by partlabel. For ordinary x86
  #   machines and VMs.
  # mode = "partition": device is one EXISTING partition (pass a stable
  #   /dev/disk/by-uuid or by-partuuid path); disko puts LUKS directly on it
  #   and never touches the partition table, the ESP, or any sibling
  #   partition. The externally-owned ESP is declared via espDevice so the
  #   /boot mount is still generated. For machines where firmware or another
  #   OS owns the disk (vizima: Asahi-allocated nvme0n1p5).
  #
  # Formatting (disko-install / disko --mode format) is destructive to the
  # declared device either way - reinstall tool only.
  options.${namespace}.disko.laptop = with types; {
    enable = mkBoolOpt false "Whether to declare the standard laptop disk layout via disko.";
    mode = mkOpt (enum [
      "disk"
      "partition"
    ]) "disk" "Claim a whole disk (GPT + ESP + LUKS) or a single existing partition (LUKS only).";
    device =
      mkOpt str "/dev/nvme0n1"
        "Disk (mode = disk) or existing partition as a stable by-uuid/by-partuuid path (mode = partition).";
    espSize = mkOpt str "1G" "EFI system partition size (mode = disk only).";
    espDevice =
      mkOpt (nullOr str) null
        "Existing ESP to mount at /boot, e.g. /dev/disk/by-uuid/E1C8-1925 (mode = partition only; never formatted).";
    luksName = mkOpt str "enc" "Name of the opened LUKS mapping (/dev/mapper/<name>).";
    vgName = mkOpt str "vg0" "LVM volume group name.";
    swapSize = mkOpt str "16G" "Swap LV size.";
    manageMounts =
      mkBoolOpt true
        "Let disko generate fileSystems/luks config. Disable on hosts installed before disko, where hardware.nix declares mounts by UUID.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.mode == "disk" -> cfg.espDevice == null;
        message = "internal.disko.laptop: espDevice is only for mode = \"partition\"; in disk mode the ESP is created and mounted by disko itself.";
      }
    ];

    disko.enableConfig = cfg.manageMounts;

    disko.devices = {
      disk.main =
        let
          luksContent = {
            type = "luks";
            name = cfg.luksName;
            settings.allowDiscards = true;
            content = {
              type = "lvm_pv";
              vg = cfg.vgName;
            };
          };
        in
        {
          type = "disk";
          device = cfg.device;
          content =
            if cfg.mode == "partition" then
              luksContent
            else
              {
                type = "gpt";
                partitions = {
                  esp = {
                    size = cfg.espSize;
                    type = "EF00";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                      mountOptions = [ "umask=0077" ];
                    };
                  };
                  luks = {
                    size = "100%";
                    content = luksContent;
                  };
                };
              };
        };

      lvm_vg.${cfg.vgName} = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = cfg.swapSize;
            content.type = "swap";
          };
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "noatime" ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "noatime" ];
                };
              };
            };
          };
        };
      };
    };

    fileSystems = mkIf cfg.manageMounts (mkMerge [
      {
        # Impermanence and the journal need these before switching root.
        "/persist".neededForBoot = true;
        "/var/log".neededForBoot = true;
      }
      (mkIf (cfg.mode == "partition" && cfg.espDevice != null) {
        # Externally-owned ESP: mounted, never formatted.
        "/boot" = {
          device = cfg.espDevice;
          fsType = "vfat";
          options = [ "umask=0077" ];
        };
      })
    ]);
  };
}
