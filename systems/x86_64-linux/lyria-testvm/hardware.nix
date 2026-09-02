{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
  ];

  boot.loader = {
    timeout = 1;
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 30;
      editor = false;
    };
  };

  disko.devices = {
    disk = {
      vda = {
        type = "disk";
        device = "/dev/vda";
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

      vdb = {
        type = "disk";
        device = "/dev/vdb";
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
          # "/rootfs" = {
          #   mountpoint = "/";
          # };
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

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=25%"
      "mode=755"
    ];
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

  environment.systemPackages = [ pkgs.btrfs-progs ];
}
